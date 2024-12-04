extends CharacterBody2D

@export var health = 3

# Constants for various actions
const SPEED = 100.0
const ATTACK_DURATION = 1.5
const ATTACK_RANGE_LONG = 100

# Variables to track states
var is_attacking = false
var attack_timeout = 0.0
var is_taking_dmg = false
var dmg_timer = 0.0
var current_direction = "Front"  # Track direction for animation ("Front", "Back", "Right", "Left")
var attack_direction = null
var player_loc = []
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
	if dead:
		return
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
	else:
		play_animation(current_direction + "-Idle")
		if !player_loc.is_empty():
			perform_attack()
		else:
			var dir = to_local(nav_agent.get_next_path_position()).normalized()
			velocity = dir * SPEED
			move_and_slide()
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
	nav_agent.target_position = player.global_position
