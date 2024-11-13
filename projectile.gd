extends CharacterBody2D

@export var speed := 350.0

func _ready() -> void:
	velocity *= speed

func _physics_process(delta: float) -> void:
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
