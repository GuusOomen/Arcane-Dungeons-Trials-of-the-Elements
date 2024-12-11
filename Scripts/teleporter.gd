extends Area2D

@export var to: int
var has_entered := false

func _on_body_entered(body: Node2D) -> void:
	if PROCESS_MODE_DISABLED == get_parent().process_mode:
		return
	if body.is_in_group("Player"):
		if has_entered:
			has_entered = false
			return
		get_tree().current_scene.teleport(to)
