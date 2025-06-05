extends Control

@onready var lose_label = $"Game Lose"
@onready var win_label = $"Game Win"
@onready var game_start_label = $"Game Start"
@onready var similarity_gradient = preload("res://similarity_gradient.tres")

func _ready():
	SignalBus.reset_ui.connect(_on_game_reset)
	SignalBus.game_lose.connect(_on_game_lose)
	SignalBus.game_win.connect(_on_game_win)
	game_start_label.visible = true
	game_start_label.text = "Can You Draw the Perfect Square?"

func _on_game_reset():
	lose_label.visible = false
	win_label.visible = false
	game_start_label.visible = false

func _on_game_lose(type: int):
	lose_label.visible = true
	game_start_label.visible = false
	match type:
		Global.LoseMessage.TRYAGAIN:
			lose_label.text = "Try Again..."
		Global.LoseMessage.WRONGWAY:
			lose_label.text = "Wrong Way!"
		Global.LoseMessage.DRAWSQUARE:
			lose_label.text = "Stay on Track!"
		Global.LoseMessage.OUTBOUNDS:
			lose_label.text = "Out of Bounds!"
		Global.LoseMessage.TOOSMALL:
			lose_label.text = "Square Too Small!"

func _on_game_win(type: int, score: float):
	win_label.visible = true
	match type:
		Global.WinMessage.OLDSCORE:
			#win_label.add_theme_color_override("font_color", similarity_gradient.sample(score/100))
			win_label.add_theme_color_override("font_color", Color.DODGER_BLUE)
			win_label.text = "Best Score: " + str("%0.2f" % score,"%")
		Global.WinMessage.HIGHSCORE:
			win_label.add_theme_color_override("font_color", similarity_gradient.sample(score/100))
			win_label.text = "New Highscore: " + str("%0.2f" % score,"%")
