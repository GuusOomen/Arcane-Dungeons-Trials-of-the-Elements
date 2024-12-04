extends Area2D

@export var type: Types.Projectile

func _ready() -> void:
	#CHange the color of the orb here
	var fire = $"AnimatedSprite2D-fire"
	var water = $"AnimatedSprite2D-water"
	var earth = $"AnimatedSprite2D-earth"
	var wind = $"AnimatedSprite2D-wind"
	print(type)
	match type:
		Types.Projectile.FIRE:
			fire.show()
		Types.Projectile.EARTH:
			earth.show()
		Types.Projectile.WATER:
			water.show()
		Types.Projectile.WIND:
			wind.show()
		_:
			print("Unknown type: ", type)

func destroy() -> void:
	call_deferred("queue_free")

func _on_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent.has_method("change_type"):
		parent.change_type(type)
		destroy()
