extends Node2D

@export var max_depth := 3
@export var min_depth := 2
@export var starting_room: PackedScene
@export var room_pool: Array[PackedScene]
@export var tree_pool: Array[PackedScene]
@export var special_rooms: Array[PackedScene]
@export var ending_pool: Array[PackedScene]

func generate_(prev_room: Node2D, prev_teleporter: Area2D, prev_room_scene: PackedScene, depth: int, path: int, has_special: bool) -> Array[Node2D]:
	var room_scene: PackedScene
	if depth == max_depth:
		if has_special:
			while path < special_rooms.size():
				if 0 == randi_range(0, 3):
					if null != special_rooms[path]:
						room_scene = special_rooms[path]
						special_rooms[path] = null
						has_special = true
						break
				else:
					break
				path += 1
			if null == room_scene:
				room_scene = ending_pool.pick_random()
		else:
			while path < special_rooms.size():
				if null != special_rooms[path]:
					room_scene = special_rooms[path]
					special_rooms[path] = null
					break
				path += 1
			if null == room_scene:
				room_scene = ending_pool.pick_random()
	elif depth < min_depth:
		if 0 != path:
			var tmp: Array[PackedScene] = room_pool + tree_pool
			room_scene = tmp.filter(func(x: PackedScene) -> bool:
				return x != prev_room_scene).pick_random()
		else:
			room_scene = room_pool.filter(func(x: PackedScene) -> bool:
				return x != prev_room_scene).pick_random()
	else:
		if 0 == randi_range(0, 1):
			if has_special:
				while path < special_rooms.size():
					if 0 == randi_range(0, 1):
						if null != special_rooms[path]:
							room_scene = special_rooms[path]
							special_rooms[path] = null
							break
					else:
						break
					path += 1
				if null == room_scene:
					room_scene = ending_pool.pick_random()
			else:
				while path < special_rooms.size():
					if null != special_rooms[path]:
						room_scene = special_rooms[path]
						special_rooms[path] = null
						has_special = true
						break
					path += 1
				if null == room_scene:
					room_scene = ending_pool.pick_random()
		else:
			if 0 != path:
				var tmp: Array[PackedScene] = room_pool + tree_pool
				room_scene = tmp.filter(func(x: PackedScene) -> bool:
					return x != prev_room_scene).pick_random()
			else:
				room_scene = room_pool.filter(func(x: PackedScene) -> bool:
					return x != prev_room_scene).pick_random()
			
	var room: Node2D = room_scene.instantiate()
	room.hide()
	room.process_mode = PROCESS_MODE_DISABLED
	room.global_position = Vector2(10000.0, 0.0)
	add_child(room)
	var teleporter: Area2D = null
	for child in room.get_children():
		if child.is_in_group("Teleporter"):
			if null == teleporter:
				child.room = prev_room
				child.teleporter = prev_teleporter
				teleporter = child
				continue
			var result := generate_(room, child, room_scene, depth + 1, path, has_special)
			child.room = result[0]
			child.teleporter = result[1]
	return [room, teleporter]

func generate() -> void:
	var room: Node2D = starting_room.instantiate()
	add_child(room)
	var path: int = 0
	var children := room.get_children()
	children.shuffle()
	for child in children:
			if child.is_in_group("Teleporter"):
				var result := generate_(room, child, starting_room, 0, path, false)
				child.room = result[0]
				child.teleporter = result[1]
				path += 1

func _ready() -> void:
	generate()
