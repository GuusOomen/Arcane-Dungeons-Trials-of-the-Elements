extends Node

@onready var player: CharacterBody2D = get_tree().get_first_node_in_group("Player")

var is_instanced: Dictionary
var current_room := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	teleport(1)

# Function to load a new room
func teleport(to: int) -> void:
	if to == current_room || 0 == to:
		return
	player.global_position = Vector2(INF, INF)
	var room_instance: Node2D = get_node("Room{0}".format([current_room]))
	if null != room_instance:
		room_instance.hide()
		room_instance.process_mode = PROCESS_MODE_DISABLED
		var walls := room_instance.get_node("Walls") as TileMapLayer
		walls.collision_enabled = false
	var has_instance := is_instanced.has(to)
	if has_instance:
		room_instance = get_node("Room{0}".format([to]))
	else:
		room_instance = load("res://Scenes/rooms/room_{0}.tscn".format([to])).instantiate()
		room_instance.hide()
		room_instance.process_mode = PROCESS_MODE_DISABLED
		add_child(room_instance)
		is_instanced[to] = 0
	var teleporter: Area2D = room_instance.get_node("Teleporter{0}".format([current_room]))
	current_room = to
	if null == teleporter:
		return
	if has_instance:
		teleporter.has_entered = true
	player.global_position = Vector2(teleporter.global_position.x, teleporter.global_position.y - 20.0)
	var walls := room_instance.get_node("Walls") as TileMapLayer
	walls.collision_enabled = true
	room_instance.process_mode = PROCESS_MODE_INHERIT
	room_instance.show()
