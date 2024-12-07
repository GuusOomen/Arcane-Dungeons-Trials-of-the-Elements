extends CharacterBody2D

@export var health = 3

# Constants for various actions
const SPEED = 100.0

# Variables to track states
var is_attacking = false
var is_taking_dmg = false
var current_direction = "Front"  # Track direction for animation ("Front", "Back", "Right", "Left")
var attack_direction = null
var player_loc = []
var dead = false

@onready var animation_player = $AnimatedSprite2D
@onready var nav_agent = $NavigationAgent2D
@onready var attack_timer = $Timers/AttackTimer
@onready var attack_timeout = $Timers/AttackTimeout
@onready var dmg_timer = $Timers/DmgTimer
@onready var nav_timer = $Timers/NavigationTimer
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var healthbar = $Healthbar

func _ready() -> void:
	healthbar.init_health(health)

func _physics_process(delta: float) -> void:
	## Determine the character's facing direction based on input
	if is_taking_dmg:
		return
	elif is_attacking:
		return
	else:
		if !player_loc.is_empty():
			perform_attack()
		else:
			var dir = to_local(nav_agent.get_next_path_position()).normalized()
			velocity = dir * SPEED
			animate_movement()
			move_and_slide()

	#move_and_slide()

func animate_movement() -> void:
	if velocity == Vector2.ZERO:
		play_animation(current_direction + "-Idle")
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
	
	play_animation(current_direction + "-Walk")

func perform_attack() -> void:
	# Set the attack animation based on the direction and range type
	play_animation(player_loc[0] + "-Idle")
	play_animation(player_loc[0] + "-Attack")
	attack_timeout.start()
	is_attacking = true
	attack_timer.start()
	attack_direction = player_loc[0]

# Helper function to play animations
func play_animation(anim_name: String) -> void:
	if animation_player.animation != anim_name:
		animation_player.play(anim_name)

func take_damage():
	is_taking_dmg = true
	attack_timer.stop()
	attack_timeout.emit_signal("timeout")
	is_attacking = false
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
	for i in get_children():
		if i != animation_player:
			i.queue_free()
	set_physics_process(false)

func _on_detect_area_entered(area: Node2D, direction: String) -> void:
	if !area.is_in_group("Hitbox"):
		return
	var parent := area.get_parent()
	if parent.is_in_group("Player") && !player_loc.has(direction):
		player_loc.insert(0, direction)


func _on_detect_area_exited(area: Node2D, direction: String) -> void:
	if area.is_in_group("Hitbox") && player_loc.has(direction):
		player_loc.remove_at(player_loc.find(direction))


func _on_attack_timer_timeout() -> void:
	if player_loc.has(attack_direction):
		player.take_damage()


func _on_navigation_timer_timeout() -> void:
	if player == null:
		return
	nav_agent.target_position = player.global_position


func _on_dmg_timer_timeout() -> void:
	is_taking_dmg = false


func _on_attack_timeout_timeout() -> void:
	is_attacking = false