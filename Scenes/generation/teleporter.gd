extends Area2D

var room: Node2D
var teleporter: Area2D

var has_entered := false

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	if has_entered:
		has_entered = false
		return
	var this_room := get_parent()
	this_room.hide()
	this_room.process_mode = PROCESS_MODE_DISABLED
	this_room.global_position = Vector2(1000, 1000)
	room.global_position = Vector2.ZERO
	room.process_mode = PROCESS_MODE_ALWAYS
	room.show()
	if null == teleporter:
		for child in room.get_children():
			if child.is_in_group("Teleporter"):
				if this_room == child.room:
					teleporter = child
					break
	teleporter.has_entered = true
	var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")
	var new_position := Vector2(teleporter.global_position.x, teleporter.global_position.y - 20.0)
	var camera: Camera2D = player.get_node("Camera2D")
	camera.global_position += new_position - player.global_position
	player.global_position = new_position
