extends CharacterBody2D

enum Mode {attack, move}

@export var health = 3

# Variable for various actions
var SPEED = 100.0
var RANGE = 300

# Variables to track states
var is_attacking = false
var is_taking_dmg = false
var current_direction = "Front"  # Track direction for animation ("Front", "Back", "Right", "Left")
var attack_direction = null
var player_loc_follow = []
var player_loc_hit = []
var is_dead = false
var mode = Mode.move
var angle_to_target = 0

@onready var animation_player = $AnimatedSprite2D
@onready var nav_agent = $NavigationAgent2D
@onready var attack_timer = $Timers/AttackTimer
@onready var attack_timeout = $Timers/AttackTimeout
@onready var slow_timer = $Timers/SlowTimer
@onready var dmg_timer = $Timers/DmgTimer
@onready var nav_timer = $Timers/NavigationTimer
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var healthbar = $Healthbar
@onready var raycast = $RayCast2D
@onready var hurtsound = $HurtSound
@onready var deadsound = $DeadSound

var projectile = preload("res://Scenes/projectile/arrow.tscn")

func _enter_tree() -> void:
	get_parent().enemy_count += 1

func _ready() -> void:
	healthbar.init_health(health)

func _physics_process(delta: float) -> void:
	if mode == Mode.attack && (not detect_char() || nav_agent.distance_to_target() >= RANGE + 100):
		stop_attack()
		mode = Mode.move
	elif mode == Mode.move && detect_char() && nav_agent.distance_to_target() <= RANGE:
		mode = Mode.attack
		
	if mode == Mode.attack:
		if is_taking_dmg:
			return
		elif is_attacking:
			target()
		else:
			play_animation(current_direction + "-Idle", false)
			target()
		
	elif mode == Mode.move:
		if is_taking_dmg:
			return
		else:
			var dir = to_local(nav_agent.get_next_path_position()).normalized()
			velocity = dir * SPEED
			animate_movement()
			move_and_slide()
	#move_and_slide()

func detect_char() -> bool:
	angle_to_target = global_position.angle_to_point(player.global_position)
	raycast.rotation = angle_to_target
	var collider = raycast.get_collider()
	if collider != null && (collider.is_in_group("Followbox") || collider.is_in_group("Hitbox")) && collider.get_parent().is_in_group("Player"):
		return true
	else:
		return false

func animate_movement() -> void:
	if velocity == Vector2.ZERO:
		play_animation(current_direction + "-Idle", false)
	else:
		if (abs(velocity.x) > abs(velocity.y)):
			if velocity.x > 0:
				current_direction = "Right"
			else:
				current_direction = "Left"
		else:
			if velocity.y > 0:
				current_direction = "Front"
			else:
				current_direction = "Back"
	
	play_animation(current_direction + "-Walk", false)

func perform_attack() -> void:
	# Set the attack animation based on the direction and range type
	play_animation(player_loc_follow[0] + "-Idle", false)
	play_animation(player_loc_follow[0] + "-Attack", false)
	attack_timeout.start()
	is_attacking = true
	attack_timer.start()
	attack_direction = player_loc_follow[0]

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
	hurtsound.play()
	if slow:
		animation_player.self_modulate = Color(0,1,1)
		animation_player.speed_scale = 0.5
		slow_timer.start()
		attack_timer.wait_time = 2
	is_taking_dmg = true
	attack_timer.stop()
	attack_timeout.emit_signal("timeout")
	is_attacking = false
	dmg_timer.start()
	if health > 1:
		health -= 1
		play_animation(current_direction + "-Hurt", false)
		healthbar.health = health
	else:
		death()
		
func death():
	deadsound.play()
	if is_dead:
		return
	set_process(false)
	set_physics_process(false)
	is_dead = true
	play_animation(current_direction + "-Death", false)
	for i in get_children():
		if i != animation_player:
			if i != deadsound:
				i.queue_free()
	remove_from_group("Enemy")
	get_parent().enemy_count -= 1


func target() -> void:
	angle_to_target = global_position.angle_to_point(player.global_position)
	raycast.rotation = angle_to_target
	var collider = raycast.get_collider()
	if collider != null && (collider.is_in_group("Followbox") || collider.is_in_group("Hitbox")):
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

func _on_attack_timer_timeout() -> void:
	play_animation(current_direction + "-Idle", false)
	var curr_projectile: CharacterBody2D = projectile.instantiate()
	curr_projectile.cast_group = "Enemy"
	curr_projectile.direction = (raycast.target_position).rotated(raycast.rotation).normalized()
	curr_projectile.global_position = global_position + 50.0 * curr_projectile.direction
	get_tree().current_scene.add_child(curr_projectile)


func _on_navigation_timer_timeout() -> void:
	if player == null:
		return
	nav_agent.target_position = player.global_position


func _on_dmg_timer_timeout() -> void:
	is_taking_dmg = false


func _on_slow_timer_timeout() -> void:
	attack_timer.wait_time = 1
	animation_player.self_modulate = Color(1,1,1)
	animation_player.speed_scale = 1
