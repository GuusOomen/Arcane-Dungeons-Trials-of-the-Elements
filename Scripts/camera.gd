extends Camera2D

func _process(delta: float) -> void:
	var follow_weight := 0.5 ** (3.0 * delta)
	global_position = lerp(get_parent().global_position, global_position, follow_weight)
