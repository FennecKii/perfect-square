extends Node2D

@export 
var distance_curve: Curve

var drawing: bool = false
var point_spacing: float = 0.005
var point_position: PackedVector2Array = []
var point_position_color: PackedColorArray = []
var point_check: PackedVector2Array = []
var pretrace_square: Rect2
var pretrace_pos_array: Array[Vector2] = []
var similarity_score: float
var drawing_bound: Rect2
var drawing_bound_small: Rect2
var time: float = 0.0
var text_speed: float = 1.0
var text_saturation_factor: float = 0.6
var curr_position: Vector2
var final_animated_color: Color
var completed: bool = false
var checkpoint_cleared: bool = false
var highscore: float
var big_bound_exited: bool = false
var small_bound_entered: bool = false
var bound_collision_delta: float = 0.2

@onready
var half_screen_rect = get_viewport_rect().size / 2
@onready 
var score_label = $Score
@onready
var title = $"Title(RGB)"
@onready
var camera = $Camera
@onready 
var checkpoint = $"Checkpoint/Checkpoint Collision"
@onready 
var small_bound_collision: CollisionShape2D = $"Small Area Bounds/Bound Collision"
@onready
var big_bound_collision: CollisionShape2D = $"Big Area Bounds/Bound Collision"
@onready
var boundary_stylebox = preload("res://stylebox_boundary.tres")
@onready
var similarity_gradient = preload("res://similarity_gradient.tres")

func _ready():
	queue_redraw()
	drawing_bound.position = Vector2(-280, -280)
	drawing_bound.size = Vector2(560, 560)
	drawing_bound_small.position = Vector2(-50, -50)
	drawing_bound_small.size = Vector2(100, 100)
	small_bound_collision.disabled = true
	big_bound_collision.disabled = true

func _process(delta):
	if similarity_score == 0:
		score_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		score_label.add_theme_color_override("font_color", similarity_gradient.sample(similarity_score/100))
	score_label.text = str(str("%0.2f" % similarity_score,"%")) if similarity_score > 0 else 'X.X%'
	update_title(delta)

func _input(event):
	handle_drawing(event)

func update_title(delta_time: float):
	time += delta_time * text_speed
	var r = sin(time) * 0.5 + 0.5
	var g = sin(time + 2.0) * 0.5 + 0.5
	var b = sin(time + 4.0) * 0.5 + 0.5
	var a = 1.0
	var animated_color = Color(r, g, b, a)
	var h = animated_color.h
	var s = animated_color.s
	var v = animated_color.v
	s *= text_saturation_factor
	final_animated_color = Color.from_hsv(h, s, v, a)
	title.add_theme_color_override("font_color", final_animated_color)
	queue_redraw()

func reset_game():
	point_position = []
	point_check = []
	pretrace_pos_array = []
	point_position_color = []
	completed = false
	checkpoint_cleared = false
	small_bound_entered = false
	big_bound_exited = false
	drawing = false

func reset_visuals():
	similarity_score = 0
	SignalBus.reset_ui.emit()
	queue_redraw()

func handle_drawing(event):
	if (event is not InputEventMouseButton) and (event is not InputEventMouseMotion):
		return
	elif completed and drawing:
		if similarity_score <= highscore:
			SignalBus.game_win.emit(0, highscore)
		elif similarity_score > highscore:
			highscore = similarity_score
			SignalBus.game_win.emit(1, similarity_score)
		drawing = false
		return
	
	curr_position = event.position - half_screen_rect + Vector2(0, camera.position.y)
	
	if small_bound_entered:
		SignalBus.game_lose.emit(4)
		similarity_score = 0
		reset_game()
		queue_redraw()
		return
	elif big_bound_exited:
		SignalBus.game_lose.emit(4)
		similarity_score = 0
		reset_game()
		queue_redraw()
		return
	
	if !drawing_bound.has_point(curr_position) and not drawing and Input.is_action_just_pressed("Draw"):
		SignalBus.game_lose.emit(3)
		similarity_score = 0
		reset_game()
		queue_redraw()
		return
	elif drawing_bound_small.has_point(curr_position) and not drawing and Input.is_action_just_pressed("Draw"):
		SignalBus.game_lose.emit(4)
		similarity_score = 0
		reset_game()
		queue_redraw()
		return
	#elif drawing_bound_small.has_point(curr_position) and drawing:
	#	SignalBus.game_lose.emit(1)
	#	similarity_score = 0
	#	drawing = false
	#	return
	elif !drawing_bound.has_point(curr_position) and drawing:
		SignalBus.game_lose.emit(3)
		similarity_score = 0
		drawing = false
		return
	
	if event is InputEventMouseButton and Input.is_action_pressed("Draw"):
		reset_game()
		reset_visuals()
		drawing = true
		point_position.append(curr_position)
		point_check.append(curr_position)
		pretrace_square = compute_pretrace_square(point_position[0])
		pretrace_pos_array = get_pretrace_array(pretrace_square, 60)
		similarity_score = 100
		set_big_collision(pretrace_square, bound_collision_delta)
		set_small_collision(pretrace_square, bound_collision_delta)
		place_checkpoint(checkpoint, Vector2(curr_position.x, curr_position.y), Vector2(100, 100))
		queue_redraw()
	elif event is InputEventMouseButton and Input.is_action_just_released("Draw"):
		drawing = false
		queue_redraw()
		small_bound_collision.disabled = true
		big_bound_collision.disabled = true
		return
	elif event is InputEventMouseMotion and not drawing and Input.is_action_just_released("Draw"):
		small_bound_collision.disabled = true
		big_bound_collision.disabled = true
		return
	
	if event is InputEventMouseMotion and drawing and Input.is_action_pressed("Draw") and not Input.is_action_just_released("Draw"):
		var similarity_vec: Vector2 = Vector2()
		if vec_len(curr_position.x - point_check[len(point_check) - 1].x, curr_position.y - point_check[len(point_check) - 1].y) >= point_spacing:
			point_check.append(curr_position)
			similarity_vec = compute_similarity(point_check, pretrace_pos_array, similarity_score)
			similarity_score = similarity_vec.x
		point_position_color.append(similarity_gradient.sample(similarity_vec.y/100))
		point_position.append(curr_position)
		queue_redraw()

func _draw():
	#handle_outline()
	
	# Drawing Area visuals
	draw_style_box(boundary_stylebox, drawing_bound)
	
	draw_circle(Vector2(0,0), 7, Color.BLACK, false, 8)
	draw_circle(Vector2(0,0), 8, final_animated_color, true)
	
	#if not drawing:
	#	draw_style_box(boundary_stylebox, drawing_bound_small)
	
	if len(point_position) < 1:
		return
	
	if len(point_position) == 1:
		draw_circle(point_position[0], 7, similarity_gradient.sample(similarity_score/100))
	else:
		draw_polyline_colors(point_position, point_position_color, 5)
	
	if not drawing:
		curr_position = point_position[len(point_position)-1]
	
	if len(point_position_color) > 0:
		draw_circle(curr_position, 7, point_position_color[len(point_position_color)-1], true)
	#if len(pretrace_pos_array) > 1:
	#	for point in pretrace_pos_array:
	#		draw_circle(point, 5, Color.REBECCA_PURPLE, true)

func handle_outline():
	draw_circle(Vector2(0, 0), 3, Color.TAN)
	if not point_position:
		return
	var dist_to_draw = min(half_screen_rect.y, compute_pretrace_square(point_position[0]).size.x / 2)
	draw_dashed_line(Vector2(0, -dist_to_draw), Vector2(0, dist_to_draw), Color.TAN, 3, 20, true, true)
	draw_dashed_line(Vector2(-dist_to_draw, 0), Vector2(dist_to_draw, 0), Color.TAN, 3, 20, true, true)

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
		pretrace_pos_array.append(Vector2(pretrace_vertex_pos[2].x - i*pos_discrim, pretrace_vertex_pos[2].y))
		pretrace_pos_array.append(Vector2(pretrace_vertex_pos[1].x, pretrace_vertex_pos[1].y + i*pos_discrim))
		pretrace_pos_array.append(Vector2(pretrace_vertex_pos[3].x, pretrace_vertex_pos[3].y - i*pos_discrim))
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
	if point_accuracy >= 90.0:
		point_accuracy_weight = (point_array_size/(point_array_size * 0.99))/point_array_size
		past_accuracy_weight = 1 - point_accuracy_weight
	elif 60.0 <= point_accuracy and point_accuracy <= 90.0:
		point_accuracy_weight = (point_array_size/(point_array_size * 0.4))/point_array_size
		past_accuracy_weight = 1 - point_accuracy_weight
	else:
		point_accuracy_weight = (point_array_size/(point_array_size * 0.2))/point_array_size
		past_accuracy_weight = 1 - point_accuracy_weight
	return Vector2((past_accuracy * past_accuracy_weight) + (point_accuracy * point_accuracy_weight), point_accuracy) 

func place_checkpoint(checkpoint: CollisionShape2D, pos: Vector2, size: Vector2):
	checkpoint.disabled = false
	var checkpoint_shape := RectangleShape2D.new()
	checkpoint_shape.size = size
	checkpoint.position = pos
	checkpoint.set_shape(checkpoint_shape)

func set_small_collision(pretrace_square: Rect2, deviation: float) -> void:
	var collision_shape: RectangleShape2D = RectangleShape2D.new()
	collision_shape.size = pretrace_square.size - pretrace_square.size * deviation
	small_bound_collision.shape = collision_shape
	small_bound_collision.disabled = false

func set_big_collision(pretrace_square: Rect2, deviation: float) -> void:
	var collision_shape: RectangleShape2D = RectangleShape2D.new()
	collision_shape.size = pretrace_square.size + pretrace_square.size * deviation
	big_bound_collision.shape = collision_shape
	big_bound_collision.disabled = false

func _on_checkpoint_mouse_entered():
	if !checkpoint_cleared:
		return
	else:
		checkpoint.disabled = true
		completed = true

func _on_checkpoint_mouse_exited():
	checkpoint_cleared = true

func _on_small_area_bounds_mouse_entered() -> void:
	small_bound_entered = true

func _on_big_area_bounds_mouse_exited() -> void:
	big_bound_exited = true
