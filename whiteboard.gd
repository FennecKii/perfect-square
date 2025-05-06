extends Node2D

@export 
var distance_curve: Curve

var drawing: bool = false
var point_spacing: float = 0.1
var point_position: PackedVector2Array = []
var point_check: PackedVector2Array = []
var pretrace_pos_array: Array[Vector2] = []
var similarity_score: float

@onready
var half_screen_rect = get_viewport_rect().size / 2
@onready 
var score_label = $Label

func _ready():
	queue_redraw()

func _process(_delta):
	score_label.text = str(similarity_score)

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
		pretrace_pos_array = get_pretrace_array(compute_pretrace_square(point_position[0]), 30)
		similarity_score = 100
		queue_redraw()
	
	if event is InputEventMouseMotion and drawing:
		if vec_len(curr_position.x - point_check[len(point_check) - 1].x, curr_position.y - point_check[len(point_check) - 1].y) >= point_spacing:
			point_check.append(curr_position)
			similarity_score = compute_similarity(point_check, pretrace_pos_array, similarity_score)
		point_position.append(curr_position)
		queue_redraw()
	
	if not drawing:
		point_position = []
		point_check = []
		pretrace_pos_array = []
		similarity_score = 0
		queue_redraw()

func _draw():
	handle_outline()
	
	if len(point_position) < 1:
		return
	
	if len(point_position) == 1:
		draw_circle(point_position[0], 5, Color.BLACK)
	else:
		draw_polyline(point_position, Color.BLACK, 5, true)
	
	if len(pretrace_pos_array) > 1:
		for point in pretrace_pos_array:
			draw_circle(point, 5, Color.REBECCA_PURPLE, true)

func handle_outline():
	draw_circle(Vector2(0, 0), 3, Color.CADET_BLUE)
	if not point_position:
		return
	var dist_to_draw = min(half_screen_rect.y, compute_pretrace_square(point_position[0]).size.x / 2)
	draw_dashed_line(Vector2(0, -dist_to_draw), Vector2(0, dist_to_draw), Color.CADET_BLUE, 3, 20, true, true)
	draw_dashed_line(Vector2(-dist_to_draw, 0), Vector2(dist_to_draw, 0), Color.CADET_BLUE, 3, 20, true, true)

func vec_len(x: float, y: float) -> float:
	return sqrt(x**2 + y**2)

func compute_pretrace_square(init_pos: Vector2) -> Rect2:
	var perfect_square: Rect2
	var square_len: float = 2 * min(max(abs(init_pos.x), abs(init_pos.y)), half_screen_rect.y)
	perfect_square.position = Vector2(-square_len / 2, -square_len / 2)
	perfect_square.size = Vector2(square_len, square_len)
	return perfect_square

func get_pretrace_array(pretrace_square: Rect2, size: int):
	var pretrace_pos_array: Array[Vector2]
	var pretrace_vertex_pos: Array[Vector2] = [
		pretrace_square.position,
		Vector2(pretrace_square.position.x + pretrace_square.size.x, pretrace_square.position.y),
		pretrace_square.end,
		Vector2(pretrace_square.position.x, pretrace_square.position.y + pretrace_square.size.y),
	]
	var pos_discrim = (pretrace_square.size).x / size
	
	for i in range(0, size):
		pretrace_pos_array.append(Vector2(pretrace_vertex_pos[0].x + i*pos_discrim, pretrace_vertex_pos[0].y))
		pretrace_pos_array.append(Vector2(pretrace_vertex_pos[3].x + i*pos_discrim, pretrace_vertex_pos[3].y))
		pretrace_pos_array.append(Vector2(pretrace_vertex_pos[0].x, pretrace_vertex_pos[0].y + i*pos_discrim))
		pretrace_pos_array.append(Vector2(pretrace_vertex_pos[1].x, pretrace_vertex_pos[1].y + i*pos_discrim))
	return pretrace_pos_array

func compute_similarity(point_check_array: Array[Vector2], pretrace_pos_array: Array[Vector2], past_accuracy: float):
	var dorff_distance: Array[float] = []
	var point_array_size: float = len(point_check_array)
	var point_accuracy: float
	var past_accuracy_weight: float
	var point_accuracy_weight: float
	var dorff_distance_vector: Vector2
	for s in pretrace_pos_array:
		dorff_distance_vector = point_check_array[point_array_size-1] - s
		dorff_distance.append(vec_len(dorff_distance_vector.x , dorff_distance_vector.y))
	point_accuracy = 100 * distance_curve.sample(dorff_distance.min())
	if point_accuracy >= 80.0:
		point_accuracy_weight = (point_array_size/(point_array_size-point_array_size/8))/point_array_size
		past_accuracy_weight = 1 - point_accuracy_weight
	elif 50.0 <= point_accuracy and point_accuracy <= 80.0:
		point_accuracy_weight = (point_array_size/(point_array_size-point_array_size/7))/point_array_size
		past_accuracy_weight = 1 - point_accuracy_weight
	else:
		point_accuracy_weight = (point_array_size/(point_array_size-point_array_size/6))/point_array_size
		past_accuracy_weight = 1 - point_accuracy_weight
	return (past_accuracy * past_accuracy_weight) + (point_accuracy * point_accuracy_weight)
