class_name WallHider
extends Area2D

func _physics_process(delta: float) -> void:
	var contains_wall := false
	for body in get_overlapping_bodies():
		if body is TileMapLayer:
			contains_wall = true
	get_parent().z_index = 2 * int(contains_wall)
