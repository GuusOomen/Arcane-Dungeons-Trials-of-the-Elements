extends CharacterBody2D

@export var health = 3

# Variables to track states
var is_attacking = false
var is_taking_dmg = false
var current_direction = "Front"  # Track direction for animation ("Front", "Back", "Right", "Left")
var attack_direction = null
var dead = false
var angle_to_target

var projectile = preload("res://Scenes/projectile/projectile-water.tscn")

@onready var animation_player = $AnimatedSprite2D
@onready var attack_timer = $Timers/AttackTimer
@onready var dmg_timer = $Timers/DmgTimer
@onready var death_timer = $Timers/DeathTimer
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var healthbar = $Healthbar
@onready var raycast = $RayCast2D
@onready var slow_timer = $Timers/SlowTimer

func _enter_tree() -> void:
	get_parent().enemy_count += 1

func _ready() -> void:
	healthbar.init_health(health)

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	## Determine the character's facing direction based on input
	if is_taking_dmg:
		return
	elif is_attacking:
		target()
	else:
		play_animation(current_direction + "-Idle", false)
		target()

func target() -> void:
	angle_to_target = global_position.angle_to_point(player.global_position)
	raycast.rotation = angle_to_target
	var collider = raycast.get_collider()
	if collider != null && (collider.is_in_group("Followbox") || collider.is_in_group("Hitbox")) && collider.get_parent().is_in_group("Player"):
		attack()
	else:
		stop_attack()

func attack() -> void:
	if PI/3 > raycast.rotation and raycast.rotation > -PI/3:
		current_direction = "Right"
	elif -PI/3 > raycast.rotation and raycast.rotation > -2*PI/3:
		current_direction = "Back"
	elif 2*PI/3 > raycast.rotation and raycast.rotation > PI/3:
		current_direction = "Front"
	else:
		current_direction = "Left"
	
	if "Attack" in animation_player.animation:
		play_animation(current_direction + "-Attack", true)
	else:
		play_animation(current_direction + "-Attack", false)
	
	if is_attacking:
		return
	
	is_attacking = true
	attack_timer.start()

func stop_attack() -> void:
	is_attacking = false
	attack_timer.stop()

# Helper function to play animations
func play_animation(anim_name: String, continuing: bool) -> void:
	if animation_player.animation == anim_name:
		return
	
	var frame = 0
	var frame_progress = 0
	
	if continuing:
		frame = animation_player.frame
		frame_progress = animation_player.frame_progress
	
	animation_player.play(anim_name)
	animation_player.set_frame_and_progress(frame, frame_progress)

func take_damage(slow):
	if slow:
		animation_player.self_modulate = Color(0,1,1)
		animation_player.speed_scale = 0.5
		slow_timer.start()
		attack_timer.wait_time = 2
	is_taking_dmg = true
	dmg_timer.start()
	if health > 1:
		health -= 1
		play_animation(current_direction + "-Hurt", false)
		healthbar.health = health
	else:
		death()

func death():
	if dead:
		return
	dead = true
	play_animation(current_direction + "-Death", false)
	for i in get_children():
		if i != animation_player:
			i.queue_free()
	death_timer.start()
	remove_from_group("Enemy")
	get_parent().enemy_count -= 1


func _on_attack_timer_timeout() -> void:
	play_animation(current_direction + "-Idle", false)
	var curr_projectile: CharacterBody2D = projectile.instantiate()
	curr_projectile.cast_group = "Enemy"
	curr_projectile.direction = (raycast.target_position).rotated(raycast.rotation).normalized()
	curr_projectile.global_position = global_position + 50.0 * curr_projectile.direction
	get_tree().current_scene.add_child(curr_projectile)


func _on_dmg_timer_timeout() -> void:
	is_taking_dmg = false


func _on_death_timer_timeout() -> void:
	queue_free()


func _on_slow_timer_timeout() -> void:
	attack_timer.wait_time = 1
	animation_player.self_modulate = Color(1,1,1)
	animation_player.speed_scale = 1
