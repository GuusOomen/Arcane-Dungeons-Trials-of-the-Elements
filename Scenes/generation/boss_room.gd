extends Node2D

var enemy_count: int : set = set_enemy_count

func set_enemy_count(new_enemy_count: int) -> void:
	if 0 == new_enemy_count:
		for child in get_children():
			if child.is_in_group("Teleporter"):
				child.process_mode = PROCESS_MODE_INHERIT
				child.show()
	enemy_count = new_enemy_count

func _enter_tree() -> void:
	for child in get_children():
			if child.is_in_group("Teleporter"):
				child.hide()
				child.process_mode = PROCESS_MODE_DISABLED

func _ready() -> void:
	for child in get_children():
		if child.is_in_group("Enemy"):
			child.process_mode = Node.PROCESS_MODE_DISABLED
	$Doors.enabled = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body)
	if body.is_in_group("Player"):
		for child in get_children():
			if child.is_in_group("Enemy"):
				child.process_mode = Node.PROCESS_MODE_INHERIT
		$Doors.enabled = true
