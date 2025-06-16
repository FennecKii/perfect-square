extends ColorRect


@onready var settings: Control = $Settings


func _ready() -> void:
	AudioManager.play_background_music(Global.background_track, -20)


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://whiteboard.tscn")


func _on_setting_pressed() -> void:
	settings.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()
