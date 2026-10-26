extends Control
func _on_play_again_button_pressed():
	await get_tree().current_scene.get_node("HUD2").fade_to_black()
	get_tree().reload_current_scene()
