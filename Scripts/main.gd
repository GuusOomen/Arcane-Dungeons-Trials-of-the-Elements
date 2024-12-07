extends Node

#Ik weet nog niet zeker of dit nodig is voor de teleporter
@export var node: Node

var player := preload("res://Scenes/Main_character.tscn")
var enemy_skeleton := preload("res://Scenes/Skeleton.tscn")
var orb := preload("res://Scenes/orb.tscn")
var starting_room := preload("res://Scenes/rooms/test_room.tscn")
var room1 := preload("res://Scenes/rooms/room_1.tscn")
var room2 := preload("res://Scenes/rooms/room_2.tscn")
var enemies = 0

# Track current state
var current_room: Node = null
var character: Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var waterorb = orb.instantiate()
	character = player.instantiate()
	var enemy = enemy_skeleton.instantiate()
	
	enemy.position = Vector2(-400,0)
	waterorb.position = Vector2(50,0)
	waterorb.type = 2
	
	#Load starting room
	_load_room(starting_room, Vector2(0, 0))
	add_child(character)
	add_child(waterorb)
	add_child(enemy)
	

# Function to load a new room
func _load_room(room_scene: PackedScene, player_start_position: Vector2) -> void:
	# Remove the current room
	if current_room:
		current_room.queue_free()
	
	# Instantiate the new room and add it to the scene
	current_room = room_scene.instantiate()
	current_room.scale = Vector2(2.5, 2.5)
	add_child(current_room)
	
	# Position the player in the new room
	if character:
		character.position = player_start_position #Dit werkt nog niet, player spawn altijd op dezelfde plek

func teleport_to_room(room_scene: PackedScene, player_start_position: Vector2) -> void:
	_load_room(room_scene, player_start_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return
	
