extends CharacterBody2D

@export var health = 3

# Variable for various actions
var SPEED = 100.0

# Variables to track states
var is_attacking = false
var is_taking_dmg = false
var current_direction = "Front"  # Track direction for animation ("Front", "Back", "Right", "Left")
var attack_direction = null
var player_loc_follow = []
var player_loc_hit = []
var is_dead = false
var slow_timer = 0.0

@onready var animation_player = $AnimatedSprite2D
@onready var nav_agent = $NavigationAgent2D
@onready var attack_timer = $Timers/AttackTimer
@onready var attack_timeout = $Timers/AttackTimeout
@onready var dmg_timer = $Timers/DmgTimer
@onready var nav_timer = $Timers/NavigationTimer
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var healthbar = $Healthbar
@onready var hurtsound = $HurtSound
@onready var deadsound = $DeadSound

func _enter_tree() -> void:
	owner.enemy_count += 1

func _ready() -> void:
	healthbar.init_health(health)

func _physics_process(delta: float) -> void:
	## Determine the character's facing direction based on input
	if slow_timer > 0:
		SPEED = 50
		slow_timer -= delta
		animation_player.self_modulate = Color(0,1,1)
	else:
		SPEED = 100
		animation_player.self_modulate = Color(1,1,1)
	if is_taking_dmg:
		return
	elif is_attacking:
		return
	else:
		if !player_loc_follow.is_empty():
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
	play_animation(player_loc_follow[0] + "-Idle")
	play_animation(player_loc_follow[0] + "-Attack")
	attack_timeout.start()
	is_attacking = true
	attack_timer.start()
	attack_direction = player_loc_follow[0]

# Helper function to play animations
func play_animation(anim_name: String) -> void:
	if animation_player.animation != anim_name:
		animation_player.play(anim_name)

func take_damage(slow):
	hurtsound.play()
	if slow:
		slow_timer = 5.0
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
		deadsound.play()
		death()
		
func death():
	deadsound.play()
	if is_dead:
		return
	set_process(false)
	set_physics_process(false)
	is_dead = true
	play_animation(current_direction + "-Death")
	for i in get_children():
		if i != animation_player:
			if i != deadsound:
				i.queue_free()
	remove_from_group("Enemy")
	owner.enemy_count -= 1

func _on_detect_area_entered(area: Node2D, direction: String) -> void:
	if area.is_in_group("Followbox"):
		var parent := area.get_parent()
		if parent.is_in_group("Player") && !player_loc_follow.has(direction):
			player_loc_follow.insert(0, direction)
	elif area.is_in_group("Hitbox"):
		var parent := area.get_parent()
		if parent.is_in_group("Player") && !player_loc_hit.has(direction):
			player_loc_hit.insert(0, direction)


func _on_detect_area_exited(area: Node2D, direction: String) -> void:
	if area.is_in_group("Followbox"):
		var parent := area.get_parent()
		if parent.is_in_group("Player") && player_loc_follow.has(direction):
			player_loc_follow.remove_at(player_loc_follow.find(direction))
	elif area.is_in_group("Hitbox"):
		var parent := area.get_parent()
		if parent.is_in_group("Player") && player_loc_hit.has(direction):
			player_loc_hit.remove_at(player_loc_hit.find(direction))


func _on_attack_timer_timeout() -> void:
	if player_loc_hit.has(attack_direction):
		player.take_damage(false)


func _on_navigation_timer_timeout() -> void:
	if player == null:
		return
	nav_agent.target_position = player.global_position


func _on_dmg_timer_timeout() -> void:
	is_taking_dmg = false


func _on_attack_timeout_timeout() -> void:
	is_attacking = false
