extends ColorRect

func _process(delta: float) -> void:
	material.set("shader_parameter/player_pos", get_tree().get_first_node_in_group("Player").global_position)
