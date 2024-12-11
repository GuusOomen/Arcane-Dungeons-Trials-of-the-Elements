extends Node2D

var is_finished := false

func _ready() -> void:
	for teleporter in get_tree().get_nodes_in_group("Teleporter"):
		teleporter.hide()
		teleporter.process_mode = PROCESS_MODE_DISABLED

func _process(delta: float) -> void:
	if is_finished:
		return
	if 0 == get_tree().get_node_count_in_group("Enemy"):
		for teleporter in get_tree().get_nodes_in_group("Teleporter"):
			teleporter.process_mode = PROCESS_MODE_INHERIT
			teleporter.show()
			is_finished = true
