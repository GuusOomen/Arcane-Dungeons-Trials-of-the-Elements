extends Node

var player := preload("res://Scenes/Main_character.tscn")
var enemy_skeleton := preload("res://Scenes/Skeleton.tscn")
var testroom := preload("res://Scenes/rooms/test_room.tscn")
var orb := preload("res://Scenes/orb.tscn")
var room1 := preload("res://Scenes/rooms/room_1.tscn")
var enemies = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var waterorb = orb.instantiate()
	var character = player.instantiate()
	var room = testroom.instantiate()
	var enemy = enemy_skeleton.instantiate()
	room.scale = Vector2(2.5,2.5)
	enemy.position = Vector2(-400,0)
	waterorb.position = Vector2(50,0)
	waterorb.type = 2
	add_child(waterorb)
	add_child(room)
	add_child(character)
	add_child(enemy)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return
