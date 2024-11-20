extends CharacterBody2D

# Constants for various actions
const SPEED = 100.0
const ATTACK_DURATION = 1.5
const ATTACK_RANGE_LONG = 100

# Variables to track states
var is_attacking = false
var attack_timeout = 0.0
var current_direction = "Front"  # Track direction for animation ("Front", "Back", "Right", "Left")
var attack_direction = null
var player_loc = []

@onready var animation_player = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
@onready var player = %Player

func _physics_process(delta: float) -> void:
	## Determine the character's facing direction based on input
	#if input_vector.x < 0 and !is_attacking:
		#current_direction = "Left"
	#elif input_vector.x > 0 and !is_attacking:
		#current_direction = "Right"
	#elif input_vector.y < 0 and !is_attacking:
		#current_direction = "Back"
	#elif input_vector.y > 0 and !is_attacking:
		#current_direction = "Front"
	if is_attacking:
		#velocity = input_vector * 0
		attack_timeout -= delta
		
		if attack_timeout <= 0:
			is_attacking = false
	else:
		play_animation(current_direction + "-Idle")
		if !player_loc.is_empty():
			perform_attack()
		## Default movement animation based on direction
		#if input_vector != Vector2.ZERO:
			#play_animation(current_direction + "-Walk")
		#else:
			#play_animation(current_direction + "-Idle")
		
		## Movement and attacks only available when not attacking
		#velocity = input_vector * SPEED

	#move_and_slide()

func perform_attack() -> void:
	# Set the attack animation based on the direction and range type
	play_animation(player_loc[0] + "-Attack")
	attack_timeout = ATTACK_DURATION
	is_attacking = true
	attack_timer.start()
	attack_direction = player_loc[0]

# Helper function to play animations
func play_animation(anim_name: String) -> void:
	if animation_player.animation != anim_name:
		animation_player.play(anim_name)


func _on_detect_body_entered(body: Node2D, direction: String) -> void:
	if body.is_in_group("player") && !player_loc.has(direction):
		player_loc.insert(0, direction)


func _on_detect_body_exited(body: Node2D, direction: String) -> void:
	if player_loc.has(direction):
		player_loc.remove_at(player_loc.find(direction))


func _on_attack_timer_timeout() -> void:
	if player_loc.has(attack_direction):
		player.take_damage()
