extends CharacterBody2D

@export var cast_group: StringName = "Player"
@export var type: Types.Projectile = Types.Projectile.DEFAULT
@export var direction := Vector2.RIGHT
@export var speed := 300.0
var slow = false

@onready var sprite = $AnimatedSprite2D
@onready var particles = $CPUParticles2D
@onready var destroy_timer = $DestroyTimer
@onready var damage_box = $Damagebox

func _ready() -> void:
	$AnimatedSprite2D.rotation = atan2(direction.y, direction.x)

func _physics_process(delta: float) -> void:
	velocity = speed * direction
	move_and_slide()
	speed *= 1.01
	if 0 != get_slide_collision_count():
		destroy()

func destroy() -> void:
	sprite.visible = false
	damage_box.collision_mask = 0
	destroy_timer.start()

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
		parent.take_damage(slow)
	
	particles.emitting = true
	destroy()


func _on_destroy_timer_timeout() -> void:
	call_deferred("queue_free")
