extends Area2D

func _physics_process(delta: float) -> void:
	var contains_wall := false
	for body in get_overlapping_bodies():
		if body is TileMapLayer:
			contains_wall = true
	get_node("../AnimatedSprite2D").z_index = int(contains_wall)
