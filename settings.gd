extends Control


func _on_x_pressed() -> void:
	visible = false
	SignalBus.settings_closed.emit()


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
