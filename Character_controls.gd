extends CharacterBody2D

@export var projectile_scene: PackedScene

# Constants for various actions
const SPEED = 200.0
const DASH_SPEED = 600.0
const ROLL_SPEED = 400.0
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
var is_taking_dmg = false
var dmg_timer = 0.0
var last_input_vector = Vector2.ZERO
var changed_direction_attack = false
var current_direction = "Front"  # Track direction for animation ("Front", "Back", "Side")
var attack_direction = ""  # Track direction for attack ("up", "down", "left", "right")

# variables to track health
var hearts_list : Array[TextureRect]
var health = 5

# variables to track upgrades
var dash_upgraded = false

@onready var animation_player = $AnimatedSprite2D

func _ready() -> void:
	var material = $AnimatedSprite2D.material
	print(material.get_shader_parameter("color_light"))
	var hearts_parent = $"../HUD/CanvasLayer/HBoxContainer"
	for child in hearts_parent.get_children():
		hearts_list.append(child)

#func get_input():
	#var input_direction := Input.get_vector("left", "right", "up", "down")
	#velocity = input_direction * SPEED

func _physics_process(delta: float) -> void:
	# Handle movement input in four directions
	var input_vector := Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	if input_vector != Vector2.ZERO:
		last_input_vector = input_vector
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
	if is_taking_dmg:
		velocity = input_vector * 0
		dmg_timer -= delta
		if dmg_timer <= 0:
			is_taking_dmg = false
	elif is_dashing:
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
		
		if Input.is_action_just_pressed("bow"):
			perform_magic()
		
		# Attack handling
		if Input.is_action_just_pressed("attack"):
			perform_attack()

		# Dash and Roll
		if Input.is_action_just_pressed("dash"):
			start_dash(last_input_vector)
		elif Input.is_action_just_pressed("roll"):
			start_roll(last_input_vector)

	move_and_slide()

var attack_counter := 0
func perform_attack() -> void:
	# Set the attack animation based on the direction and range type
	if 0 == attack_counter % 2:
		play_animation(current_direction + "-Slash-1")
		attack_timer = ATTACK_DURATION_SHORT
	else:
		play_animation(current_direction + "-Slash-2")
		attack_timer = ATTACK_DURATION_SHORT
	is_attacking = true
	changed_direction_attack = false
	attack_counter += 1

func perform_magic() -> void:
	var projectile := projectile_scene.instantiate() as CharacterBody2D
	projectile.cast_group = "Player"
	projectile.direction = (get_global_mouse_position() - global_position).normalized()
	projectile.global_position = global_position + 50.0 * projectile.direction
	get_tree().current_scene.add_child(projectile)

func start_dash(direction: Vector2) -> void:
	is_dashing = true
	dash_timer = 0.2
	velocity = (direction * DASH_SPEED)
	play_animation(current_direction + "-Dash")

func start_roll(direction: Vector2) -> void:
	is_rolling = true
	roll_timer = ROLL_DURATION
	velocity = (direction * 0.5 * ROLL_SPEED)
	play_animation(current_direction + "-Roll")

# Helper function to play animations
func play_animation(anim_name: String) -> void:
	if animation_player.animation != anim_name:
		animation_player.play(anim_name)

func heal():
	if health < 5:
		health += 1
		update_heart_display_heal()

func take_damage():
	is_taking_dmg = true
	dmg_timer = 0.4
	if health > 0:
		health -= 1
		play_animation(current_direction + "-Hit")
		update_heart_display_dmg()
	#if health == 0:
		#dead()

func change_type(type):

	print(type)

func update_heart_display_dmg():
	for i in range(hearts_list.size()):
		if i == health:
			hearts_list[i].get_child(0).play("Hit")

func update_heart_display_heal():
	for i in range(hearts_list.size()):
		if i == health - 1:
			hearts_list[i].get_child(0).play("Heal")
