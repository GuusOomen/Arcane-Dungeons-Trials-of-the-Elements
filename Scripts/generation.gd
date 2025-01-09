extends Node2D

@export var max_depth := 6
@export var min_depth := 3
@export var starting_room: PackedScene
@export var room_pool: Array[PackedScene]
@export var ending_pool: Array[PackedScene]

func generate_(prev_room: Node2D, prev_teleporter: Area2D, prev_room_scene: PackedScene, depth: int) -> Array[Node2D]:
	var room_scene: PackedScene
	if depth == max_depth:
		room_scene = ending_pool.pick_random()
	elif depth < min_depth:
		room_scene = room_pool.pick_random()
	else:
		room_scene = (room_pool + ending_pool).pick_random()
	var room: Node2D = room_scene.instantiate()
	room.hide()
	room.process_mode = PROCESS_MODE_DISABLED
	room.global_position = Vector2(10000.0, 0.0)
	add_child(room)
	var teleporter: Area2D
	for child in room.get_children():
		if child.is_in_group("Teleporter"):
			if null == teleporter:
				child.room = prev_room
				child.teleporter = prev_teleporter
				teleporter = child
				continue
			var result := generate_(room, child, starting_room, depth + 1)
			child.room = result[0]
			child.teleporter = result[1]
	return [room, teleporter]

func generate() -> void:
	var room: Node2D = starting_room.instantiate()
	add_child(room)
	for child in room.get_children():
			if child.is_in_group("Teleporter"):
				var result := generate_(room, child, starting_room, 0)
				child.room = result[0]
				child.teleporter = result[1]

func _ready() -> void:
	generate()
