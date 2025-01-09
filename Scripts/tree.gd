extends StaticBody2D

var is_burning := false
@onready var burnsound = $BurnSound

func set_percent(percentage: float) -> void:
	$AnimatedSprite2D.material.set("shader_parameter/percentage", percentage)

func destroy() -> void:
	if is_burning:
		return
	is_burning = true
	burnsound.play()
	var tween = get_tree().create_tween()
	tween.tween_method(set_percent, 0.8, 0.0, 2.5)
	$CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionPolygon2D.set_deferred("disabled", true)
	await get_tree().create_timer(2.5).timeout
	call_deferred("queue_free")
