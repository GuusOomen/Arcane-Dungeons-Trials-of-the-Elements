extends Node

var player := preload("res://Main_character.tscn")
var testroom := preload("res://rooms/test_room.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var character = player.instantiate()
	var room = testroom.instantiate()
	room.scale = Vector2(2.5,2.5)
	add_child(room)
	add_child(character)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
