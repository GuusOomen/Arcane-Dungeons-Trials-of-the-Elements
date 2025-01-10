extends Area2D

var room: Node2D
var teleporter: Area2D
var is_pressable: bool


@onready var animation_player = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_pressable = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_pressable = false

func _process(delta: float) -> void:
	if is_pressable && Input.is_action_just_pressed("interact") && $Sprite2D.visible:
		for projectile: CharacterBody2D in get_tree().get_nodes_in_group("Projectile"):
			projectile.call_deferred("queue_free")
		var this_room := get_parent()
		this_room.global_position = Vector2(10000.0, 0.0)
		var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
		player.get_node("Camera2D").global_position += teleporter.position - player.global_position
		player.teleport(teleporter.position)
		# play beam animation
		teleporter.animation_player.stop()
		teleporter.animation_player.play("beam")
		room.global_position = Vector2.ZERO
		room.process_mode = PROCESS_MODE_INHERIT
		room.show()
		this_room.hide()
		this_room.process_mode = PROCESS_MODE_DISABLED


func sprite_visibility(enable) -> void:
	$Sprite2D.visible = enable
	$PointLight2D.visible = enable
	$CPUParticles2D.visible = enable
