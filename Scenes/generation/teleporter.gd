extends Area2D

var room: Node2D
var teleporter: Area2D
var is_pressable: bool

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_pressable = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_pressable = false

func _process(delta: float) -> void:
	if is_pressable && Input.is_action_just_pressed("interact"):
		var this_room := get_parent()
		this_room.hide()
		this_room.process_mode = PROCESS_MODE_DISABLED
		this_room.global_position = Vector2(10000.0, 0.0)
		var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
		player.teleport()
		player.get_node("Camera2D").global_position += teleporter.position - player.global_position
		player.global_position = teleporter.position
		room.global_position = Vector2.ZERO
		room.process_mode = PROCESS_MODE_INHERIT
		room.show()
