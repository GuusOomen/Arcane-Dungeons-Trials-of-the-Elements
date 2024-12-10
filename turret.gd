extends CharacterBody2D

@export var health = 3

# Constants for various actions
const ATTACK_RANGE_LONG = 200

# Variables to track states
var is_attacking = false
var is_taking_dmg = false
var current_direction = "Front"  # Track direction for animation ("Front", "Back", "Right", "Left")
var attack_direction = null
var dead = false
var angle_to_target

var projectile = preload("res://projectile/projectile-water.tscn")

@onready var animation_player = $AnimatedSprite2D
@onready var attack_timer = $Timers/AttackTimer
@onready var attack_timeout = $Timers/AttackTimeout
@onready var dmg_timer = $Timers/DmgTimer
@onready var death_timer = $Timers/DeathTimer
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var healthbar = $Healthbar
@onready var raycast = $RayCast2D

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
		play_animation(current_direction + "-Idle")
		target()

	#move_and_slide()

func target() -> void:
	angle_to_target = global_position.angle_to_point(player.global_position)
	raycast.rotation = angle_to_target
	var collider = raycast.get_collider()
	if collider != null && collider.get_parent() == player:
		attack()
	else:
		stop_attack()

func attack() -> void:
	if is_attacking:
		return
	
	is_attacking = true
	attack_timer.start()
	play_animation(current_direction + "-Attack")

func stop_attack() -> void:
	is_attacking = false
	attack_timer.stop()

# Helper function to play animations
func play_animation(anim_name: String) -> void:
	if animation_player.animation != anim_name:
		animation_player.play(anim_name)

func take_damage():
	is_taking_dmg = true
	dmg_timer.start()
	if health > 1:
		health -= 1
		play_animation(current_direction + "-Hurt")
		healthbar.health = health
	else:
		death()

func death():
	dead = true
	play_animation(current_direction + "-Death")
	death_timer.start()


func _on_attack_timer_timeout() -> void:
	var curr_projectile: CharacterBody2D = projectile.instantiate()
	curr_projectile.cast_group = "Enemy"
	curr_projectile.direction = (raycast.target_position).rotated(raycast.rotation).normalized()
	curr_projectile.global_position = global_position + 50.0 * curr_projectile.direction
	get_tree().current_scene.add_child(curr_projectile)
	print("shot")


func _on_attack_timeout_timeout() -> void:
	pass


func _on_dmg_timer_timeout() -> void:
	is_taking_dmg = false


func _on_death_timer_timeout() -> void:
	queue_free()
