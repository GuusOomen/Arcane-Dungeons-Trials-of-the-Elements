extends Node2D

var enemy_count: int : set = set_enemy_count

func set_enemy_count(new_enemy_count: int) -> void:
	if 0 == new_enemy_count:
		for child in get_children():
			if child.is_in_group("Teleporter"):
				child.has_entered = false
				child.process_mode = PROCESS_MODE_INHERIT
				child.show()
	enemy_count = new_enemy_count

func _enter_tree() -> void:
	for child in get_children():
			if child.is_in_group("Teleporter"):
				child.hide()
				child.process_mode = PROCESS_MODE_DISABLED
