extends Area2D

var is_pressable: bool

var bg: ColorRect
var vignette: ColorRect

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_pressable = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_pressable = false
		
func tween_exposure(exposure: float) -> void:
	bg.material.set("shader_parameter/exposure", exposure)
	
func tween_bg_color(color: Color) -> void:
	bg.color = color

func tween_vignette_color(color: Color) -> void:
	vignette.color = color

func _process(_delta: float) -> void:
	if is_pressable && Input.is_action_just_pressed("interact"):
		var player := get_tree().get_first_node_in_group("Player")
		player.backgroundsound.stop()
		player.teleport(Vector2(-20.0, 1684.0))
		if player.types.size() < 4:
			for i in range(5):
				player.take_damage(false)
		else:
			bg = get_tree().current_scene.find_child("BG")
			vignette = get_tree().current_scene.find_child("Vignette")
			var tween1: Tween = get_tree().current_scene.create_tween()
			var tween2: Tween = get_tree().current_scene.create_tween()
			var tween3: Tween = get_tree().current_scene.create_tween()
			tween1.tween_method(tween_exposure, 1.0, 5.0, 0.5)
			tween2.tween_method(tween_bg_color, bg.color, Color(255 / 255.0, 234 / 255.0, 128 / 255.0, 0.5), 0.5)
			tween3.tween_method(tween_vignette_color, vignette.color, Color(255 / 255.0, 234 / 255.0, 128 / 255.0, 0.5), 0.5)
			tween1.play()
			tween2.play()
			tween3.play()
		hide()
		process_mode = PROCESS_MODE_DISABLED
