extends Node

signal reset_ui
signal game_start(type: int)
signal game_lose(type: int)
signal game_win(type: int, score: float)
signal settings_closed
