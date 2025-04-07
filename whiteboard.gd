extends Node2D

var drawing: bool = false
var point_spacing: float = 20
var point_position: PackedVector2Array = []
var point_check: PackedVector2Array = []

@onready
var half_screen_rect = get_viewport_rect().size / 2

func _ready():
	queue_redraw()
	

func _input(event):
	handle_drawing(event)

func handle_drawing(event):
	if (event is not InputEventMouseButton) and (event is not InputEventMouseMotion):
		return
	
	var curr_position = event.position - half_screen_rect
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
	handle_outline()
	
	if len(point_position) < 1:
		return
		
	if len(point_position) == 1:
		draw_circle(point_position[0], 10, Color.BLACK)
	else:
		draw_polyline(point_position, Color.BLACK, 10, true)
		
func handle_outline():
	draw_circle(Vector2(0, 0), 3, Color.CADET_BLUE)
	if not point_position:
		return
	var dist_to_draw = max(abs(point_position[0].y), abs(point_position[0].x))
	
	draw_dashed_line(Vector2(0, 0), Vector2(0, dist_to_draw), Color.CADET_BLUE, 3, 20, true, true)
	draw_dashed_line(Vector2(0, 0), Vector2(0, -dist_to_draw), Color.CADET_BLUE, 3, 20, true, true)
	draw_dashed_line(Vector2(0, 0), Vector2(dist_to_draw, 0), Color.CADET_BLUE, 3, 20, true, true)
	draw_dashed_line(Vector2(0, 0), Vector2(-dist_to_draw, 0), Color.CADET_BLUE, 3, 20, true, true)

func vec_len(x: float, y: float) -> float:
	return sqrt(x**2 + y**2)

func compute_pretrace_square(init_pos: Vector2) -> Rect2:
	var perfect_square: Rect2
	var square_len: float = 2 * max(abs(init_pos.x), abs(init_pos.y))
	perfect_square.position = Vector2(-square_len / 2, -square_len / 2)
	perfect_square.size = Vector2(square_len, square_len)
	return perfect_square
