extends Area2D

@export var to: int
var has_entered := true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if has_entered:
			has_entered = false
			return
		get_tree().current_scene.teleport(to)
