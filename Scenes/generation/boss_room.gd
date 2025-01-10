extends Node2D

var wave = 1

var enemy_count: int : set = set_enemy_count
var entered: bool = false

@onready var doors = $Doors
@onready var door_sfx = $BossRoomDoor

func set_enemy_count(new_enemy_count: int) -> void:
	if -1 == new_enemy_count:
		var ending := get_node("Ending")
		ending.process_mode = PROCESS_MODE_INHERIT
		ending.show()
	enemy_count = new_enemy_count

func _ready() -> void:
	var ending := get_node("Ending")
	ending.hide()
	ending.process_mode = PROCESS_MODE_DISABLED
	
	for child in $Wave1.get_children():
		if child.is_in_group("Enemy"):
			child.process_mode = Node.PROCESS_MODE_DISABLED
			
	for child in $Wave2.get_children():
		if child.is_in_group("Enemy"):
			child.process_mode = Node.PROCESS_MODE_DISABLED
			child.visible = false
			enemy_count -= 1
			
	for child in $Wave3.get_children():
		if child.is_in_group("Enemy"):
			child.process_mode = Node.PROCESS_MODE_DISABLED
			child.visible = false
			enemy_count -= 1
	
	$Doors.enabled = false

func _process(_delta: float) -> void:
	if enemy_count == 0:
		wave += 1
		var wave_node = get_node("Wave{0}".format([wave]))
		if wave_node == null:
			enemy_count = -1
			return
			
		for child in wave_node.get_children():
			child.process_mode = Node.PROCESS_MODE_INHERIT
			child.visible = true
			enemy_count += 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if entered:
		return
	if body.is_in_group("Player"):
		for child in $Wave1.get_children():
			if child.is_in_group("Enemy"):
				child.process_mode = Node.PROCESS_MODE_INHERIT
		
		doors.enabled = true
		door_sfx.play()
		entered = true
