extends CharacterBody2D

@export var health = 3

# Constants for various actions
const ATTACK_DURATION = 1.5
const ATTACK_RANGE_LONG = 100

# Variables to track states
var is_attacking = false
var attack_timeout = 0.0
var is_taking_dmg = false
var dmg_timer = 0.0
var current_direction = "Front"  # Track direction for animation ("Front", "Back", "Right", "Left")
var attack_direction = null
var dead = false

@onready var animation_player = $AnimatedSprite2D
@onready var nav_agent = $NavigationAgent2D
@onready var attack_timer = $AttackTimer
@onready var nav_timer = $NavigationTimer
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var healthbar = $Healthbar

func _ready() -> void:
	healthbar.init_health(health)

func _physics_process(delta: float) -> void:
	## Determine the character's facing direction based on input
	if is_taking_dmg:
		dmg_timer -= delta
		
		if dmg_timer <= 0:
			is_taking_dmg = false
	elif is_attacking:
		#velocity = input_vector * 0
		attack_timeout -= delta
		
		if attack_timeout <= 0:
			is_attacking = false

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
	play_animation(current_direction + "-Attack")
	attack_timeout = ATTACK_DURATION
	is_attacking = true
	attack_timer.start()

# Helper function to play animations
func play_animation(anim_name: String) -> void:
	if animation_player.animation != anim_name:
		animation_player.play(anim_name)

func take_damage():
	is_taking_dmg = true
	dmg_timer = 0.4
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
