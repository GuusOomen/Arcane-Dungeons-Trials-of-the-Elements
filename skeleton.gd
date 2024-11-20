extends CharacterBody2D

# Constants for various actions
const SPEED = 100.0
const ATTACK_DURATION = 1.5
const ATTACK_RANGE_LONG = 100

# Variables to track states
var is_attacking = false
var attack_timer = 0.0
var current_direction = "Front"  # Track direction for animation ("Front", "Back", "Right", "Left")
var attack_direction = ""  # Track direction for attack ("up", "down", "left", "right")

@onready var animation_player = $AnimatedSprite2D

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * SPEED

func _physics_process(delta: float) -> void:
	# Handle movement input in four directions
	var input_vector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	# Determine the character's facing direction based on input
	if input_vector.x < 0 and !is_attacking:
		current_direction = "Left"
	elif input_vector.x > 0 and !is_attacking:
		current_direction = "Right"
	elif input_vector.y < 0 and !is_attacking:
		current_direction = "Back"
	elif input_vector.y > 0 and !is_attacking:
		current_direction = "Front"

	if is_attacking:
		velocity = input_vector * 0
		attack_timer -= delta
		
		if attack_timer <= 0:
			is_attacking = false
	else:
		# Default movement animation based on direction
		if input_vector != Vector2.ZERO:
			play_animation(current_direction + "-Walk")
		else:
			play_animation(current_direction + "-Idle")
		
		# Movement and attacks only available when not dashing, rolling, or attacking
		velocity = input_vector * SPEED
		
		# Attack handling
		if Input.is_action_just_pressed("attack"):
			perform_attack()

	move_and_slide()

func perform_attack() -> void:
	# Set the attack animation based on the direction and range type
	play_animation(current_direction + "-Attack")
	attack_timer = ATTACK_DURATION
	is_attacking = true

# Helper function to play animations
func play_animation(anim_name: String) -> void:
	if animation_player.animation != anim_name:
		animation_player.play(anim_name)
