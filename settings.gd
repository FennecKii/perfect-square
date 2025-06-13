extends Control


func _on_x_pressed() -> void:
	visible = false
	SignalBus.settings_closed.emit()
