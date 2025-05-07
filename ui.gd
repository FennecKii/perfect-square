extends Control

@onready
var lose_label = $"Game Lose"
@onready
var win_label = $"Game Win"

func _ready():
	SignalBus.reset_ui.connect(_on_game_reset)
	SignalBus.game_lose.connect(_on_game_lose)
	SignalBus.game_win.connect(_on_game_win)

func _on_game_reset():
	lose_label.visible == false
	win_label.visible == false

func _on_game_lose(type: int):
	lose_label.visible == true
	if type == 0:
		lose_label.text = "Try Again :("
	elif type == 1:
		lose_label.text = "Wrong Way!"
	elif type == 2:
		lose_label.text = "Please Draw A Square."

func _on_game_win(type: int, score: float):
	win_label.visible == true
	if type == 0:
		win_label.text = "Best Score: " + str(score)
	elif type == 1:
		win_label.text = "New Highscore: " + str(score)
