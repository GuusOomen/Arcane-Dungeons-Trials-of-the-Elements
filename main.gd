extends Node

var player := preload("res://Main_character.tscn")
var testroom := preload("res://rooms/test_room.tscn")
var orb := preload("res://orb.tscn")
var room1 := preload("res://rooms/room_1.tscn")
var enemies = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var waterorb = orb.instantiate()
	var character = player.instantiate()
	var room = testroom.instantiate()
	room.scale = Vector2(2.5,2.5)
	waterorb.position = Vector2(50,0)
	waterorb.type = "wind"
	add_child(waterorb)
	add_child(room)
	add_child(character)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return
