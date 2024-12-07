extends Area2D

@export var target_room: PackedScene
@export var target_position: Vector2 = Vector2()
var entered = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("Played entered")
		entered = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		entered = false
		print("Player Exited")

func _process(delta: float) -> void:
	var main = get_node("/root/Node")
	if entered && Input.is_action_just_pressed("ui_accept"): #Enter button is pressed
		main.teleport_to_room(target_room, target_position)
	
