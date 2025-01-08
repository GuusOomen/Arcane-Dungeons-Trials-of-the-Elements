extends Node2D

@export var starting_room: PackedScene
@export var room_pool: Array[PackedScene]

func generate_(prev_room: Node2D, prev_room_scene: PackedScene) -> Node2D:
	var room_scene: PackedScene = room_pool.pick_random()
	while room_scene == prev_room_scene:
		room_scene = room_pool.pick_random()
	var room: Node2D = room_scene.instantiate()
	room.hide()
	room.process_mode = PROCESS_MODE_DISABLED
	room.global_position = Vector2(10000.0, 0.0)
	var is_first := true
	for child in room.get_children():
		if child.is_in_group("Teleporter"):
			if is_first:
				is_first = false
				child.room = prev_room
				continue
			child.room = generate_(room, room_scene)
	add_child(room)
	return room

func generate() -> void:
	var room: Node2D = starting_room.instantiate()
	add_child(room)
	for child in room.get_children():
			if child.is_in_group("Teleporter"):
				child.room = generate_(room, starting_room)

func _ready() -> void:
	generate()
