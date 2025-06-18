extends Node

enum LoseMessage {
	TRYAGAIN,
	WRONGWAY,
	DRAWSQUARE,
	OUTBOUNDS,
	TOOSMALL,
	TIMEOUT
	}

enum WinMessage {
	OLDSCORE,
	HIGHSCORE
	}

@onready var background_track = preload("res://audio/Casual Vol2 Happy Hour Intensity 1AAA A.wav")
@onready var highscore_sfx = preload("res://audio/start.wav")
@onready var lose_sfx = preload("res://audio/error-126627.wav")
@onready var progress_sfx = preload("res://audio/press.wav")
@onready var slider_scroll_sfx = preload("res://audio/scroll_new.wav")
@onready var button_press_sfx = preload("res://audio/release_2.wav")

var button_press_volume: float = 1.5
var button_press_pitch: float = 1
var button_press_pitch_variation: float = 0.15
