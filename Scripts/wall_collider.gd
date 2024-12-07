extends CharacterBody2D

func _physics_process(delta: float) -> void:
	move_and_slide()
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		if collision.get_collider() is TileMapLayer:
			get_parent().
