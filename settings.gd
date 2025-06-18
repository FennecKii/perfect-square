extends Control


func _on_x_pressed() -> void:
	visible = false
	SignalBus.settings_closed.emit()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_button_pressed() -> void:
	AudioManager.play_sfx(Global.button_press_sfx, Global.button_press_volume, Global.button_press_pitch, Global.button_press_pitch_variation)
