extends CharacterBody2D

@export var cast_group: StringName = "Player"
@export var direction := Vector2.RIGHT
@export var speed := 300.0

func _process(delta: float) -> void:
	$Sprite2D.z_index = global_position.y / 10

func _physics_process(delta: float) -> void:
	velocity = speed * direction
	move_and_slide()
	speed *= 1.01

func destroy() -> void:
	call_deferred("queue_free")

func _on_damagebox_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Hitbox"):
		return
	var parent := area.get_parent()
	if parent.is_in_group(cast_group):
		return
	if parent.has_method("take_damage"):
		parent.take_damage()
	destroy()
