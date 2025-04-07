extends Node2D

var drawing: bool = false
var point_spacing: float = 20
var point_position: PackedVector2Array = []
var point_check: PackedVector2Array = []

func _input(event):
	var curr_position = event.position - (get_viewport_rect().size / 2)
	if event is InputEventMouseButton:
		drawing = event.is_pressed()
		point_position.append(curr_position)
		point_check.append(curr_position)
		queue_redraw()
	
	if event is InputEventMouseMotion and drawing:
		if vec_len(curr_position.x - point_check[len(point_check) - 1].x, curr_position.y - point_check[len(point_check) - 1].y) >= point_spacing:
			point_check.append(curr_position)
		point_position.append(curr_position)
		queue_redraw()
	
	if not drawing:
		point_position = []
		point_check = []
		queue_redraw()

func _draw():
	if len(point_position) < 1:
		return
		
	if len(point_position) == 1:
		draw_circle(point_position[0], 10, Color.BLACK)
	else:
		draw_polyline(point_position, Color.BLACK, 10, true)

func vec_len(x: float, y: float) -> float:
	return sqrt(x**2 + y**2)
