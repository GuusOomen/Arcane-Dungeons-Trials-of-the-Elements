extends CharacterBody2D

@export var cast_group: StringName = "Player"
@export var type: Types.Projectile = Types.Projectile.DEFAULT
@export var direction := Vector2.RIGHT
@export var speed := 300.0
var slow = false

func _ready() -> void:
	$AnimatedSprite2D.rotation = atan2(direction.y, direction.x)

func _physics_process(delta: float) -> void:
	velocity = speed * direction
	move_and_slide()
	speed *= 1.01
	if 0 != get_slide_collision_count():
		destroy()

func destroy() -> void:
	call_deferred("queue_free")

func _on_damagebox_area_entered(area: Area2D) -> void:
	if not area.is_in_group("Hitbox"):
		return
	var parent := area.get_parent()
	if Types.Projectile.WATER == type:
		slow = true
	if parent.is_in_group(cast_group):
		return
	if parent.is_in_group("Tree"):
		if Types.Projectile.FIRE == type:
			parent.destroy()
			destroy()
		return
	if parent.has_method("take_damage"):
		print(slow)
		parent.take_damage(slow)
	destroy()
