extends Area2D

@export var cast_group: StringName = "Player"
@export var type : String

func _on_ready() -> void:
	#CHange the color of the orb here
	return

func destroy() -> void:
	call_deferred("queue_free")

func _on_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent.has_method("change_type"):
		parent.change_type(type)
	destroy()
