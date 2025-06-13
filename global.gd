extends Node

enum LoseMessage {
	TRYAGAIN,
	WRONGWAY,
	DRAWSQUARE,
	OUTBOUNDS,
	TOOSMALL
	}

enum WinMessage {
	OLDSCORE,
	HIGHSCORE
	}

@onready var background_track = preload("res://audio/Casual Vol2 Happy Hour Intensity 1AAA A.wav")
@onready var highscore_sfx = preload("res://audio/start.wav")
@onready var lose_sfx = preload("res://audio/error-126627.wav")
@onready var progress_sfx = preload("res://audio/press.wav")

var master_volume: float
var music_volume: float
var SFX_volume: float
