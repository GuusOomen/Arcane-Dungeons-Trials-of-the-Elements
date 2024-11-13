extends CharacterBody2D

# Constants for various actions
const SPEED = 200.0
const DASH_SPEED = 600.0
const ROLL_DURATION = 0.6
const ATTACK_DURATION_SHORT = 0.6
const ATTACK_DURATION_LONG = 1.06
const ATTACK_LONG_SECOND_SLASH = 0.56
const ATTACK_RANGE_SHORT = 50
const ATTACK_RANGE_LONG = 100
const ARROW_SPEED = 500.0

# Variables to track states
var is_dashing = false
var dash_timer = 0.0
var is_rolling = false
var roll_timer = 0.0
var is_attacking = false
var attack_timer = 0.0
var changed_direction_attack = false
var current_direction = "Front"  # Track direction for animation ("Front", "Back", "Side")
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
		current_direction = "Side"
		animation_player.flip_h = true
	elif input_vector.x > 0 and !is_attacking:
		current_direction = "Side"
		animation_player.flip_h = false
	elif input_vector.y < 0 and !is_attacking:
		current_direction = "Back"
	elif input_vector.y > 0 and !is_attacking:
		current_direction = "Front"

	# Manage dashing and rolling states
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	elif is_rolling:
		roll_timer -= delta
		if roll_timer <= 0:
			is_rolling = false
	elif is_attacking:
		velocity = input_vector * 0
		attack_timer -= delta
		
		if attack_timer <= 0:
			is_attacking = false
		# Script to change direction in attack
		# print((attack_timer < (ATTACK_LONG_SECOND_SLASH - 0.1)) and (attack_timer > (ATTACK_LONG_SECOND_SLASH + 0.1)))
		if (ATTACK_LONG_SECOND_SLASH - 0.1 < attack_timer and ATTACK_LONG_SECOND_SLASH + 0.1 > attack_timer and !changed_direction_attack):
			if input_vector.x < 0 and (current_direction != "Side" or animation_player.flip_h != true):
				animation_player.flip_h = true
				changed_direction_attack = true
			elif input_vector.x > 0 and (current_direction != "Side" or animation_player.flip_h != false):
				animation_player.flip_h = false
				changed_direction_attack = true
	else:
		# Default movement animation based on direction
		if input_vector != Vector2.ZERO:
			play_animation(current_direction + "-Walk")
		else:
			play_animation(current_direction + "-Base")
		
		# Movement and attacks only available when not dashing, rolling, or attacking
		velocity = input_vector * SPEED
		
		# Attack handling
		if Input.is_action_just_pressed("attack"):
			perform_attack("short")
		elif Input.is_action_just_pressed("long_attack"):
			perform_attack("long")

		# Dash and Roll
		if Input.is_action_just_pressed("dash"):
			start_dash(input_vector)
		elif Input.is_action_just_pressed("roll"):
			start_roll()

	move_and_slide()

func perform_attack(range_type: String) -> void:
	# Set the attack animation based on the direction and range type
	if range_type == "short":
		play_animation(current_direction + "-Slash-1-short")
		attack_timer = ATTACK_DURATION_SHORT
	else:
		play_animation(current_direction + "-Slash-2-long")
		attack_timer = ATTACK_DURATION_LONG
	is_attacking = true
	changed_direction_attack = false

func start_dash(direction: Vector2) -> void:
	is_dashing = true
	dash_timer = 0.2
	velocity = direction * DASH_SPEED
	play_animation(current_direction + "-Dash")

func start_roll() -> void:
	is_rolling = true
	roll_timer = ROLL_DURATION
	play_animation(current_direction + "-Roll")

# Helper function to play animations
func play_animation(anim_name: String) -> void:
	if animation_player.animation != anim_name:
		animation_player.play(anim_name)
