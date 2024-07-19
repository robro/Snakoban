class_name Snake
extends Node

var points: Array[Vector2i]
var tail: Vector2i
var auto_move_timer := Timer.new()

signal want_move_to(point: Vector2i, direction: Vector2i)


func _init(_points: Array[Vector2i]) -> void:
	assert(_points.size() > 1)
	points = _points
	tail = _points[-1]


func _ready() -> void:
	auto_move_timer.wait_time = 0.5
	auto_move_timer.one_shot = false
	auto_move_timer.connect("timeout", _on_autoMoveTimer_timeout)
	add_child(auto_move_timer)


func _physics_process(_delta: float) -> void:
	if (Input.is_action_just_pressed("up") or
		Input.is_action_just_pressed("down") or
		Input.is_action_just_pressed("left") or
		Input.is_action_just_pressed("right")
	):
		handle_input()
		auto_move_timer.wait_time = 0.4
		auto_move_timer.start()


func _on_autoMoveTimer_timeout() -> void:
	handle_input()
	auto_move_timer.wait_time = 0.1
	auto_move_timer.start()


func handle_input() -> void:
	var facing := Vector2.from_angle(Vector2(points[1]).angle_to_point(points[0]))

	if Input.is_action_pressed("up") and facing != Vector2.DOWN:
		try_move(Vector2i.UP)

	elif Input.is_action_pressed("down") and facing != Vector2.UP:
		try_move(Vector2i.DOWN)

	elif Input.is_action_pressed("left") and facing != Vector2.RIGHT:
		try_move(Vector2i.LEFT)

	elif Input.is_action_pressed("right") and facing != Vector2.LEFT:
		try_move(Vector2i.RIGHT)


func try_move(direction: Vector2i) -> void:
	var point := points[0] + direction

	if point in points:
		return

	emit_signal("want_move_to", point, direction)


func move_to(point: Vector2i) -> void:
	tail = points.pop_back()
	points.insert(0, point)


func grow() -> void:
	points.append(tail)


func get_tile(i: int) -> Vector2i:
	var start_tile := Vector2i.ZERO
	var tile_offset := Vector2i.ZERO
	var angle_to_next := 0.0
	var angle_from_prev := 0.0

	if i - 1 >= 0:
		angle_from_prev = positive_angle(points[i - 1], points[i])

	if i + 1 < points.size():
		angle_to_next = positive_angle(points[i], points[i + 1])

	if i == 0:
		start_tile = Vector2i.ZERO
		tile_offset = Vector2i(roundi(angle_to_next / (PI / 2)), 0)

	elif i == points.size() - 1:
		start_tile = Vector2i(0, 3)
		tile_offset = Vector2i(roundi(angle_from_prev / (PI / 2)), 0)

	elif angle_to_next == angle_from_prev:
		start_tile = Vector2i(0, 1)
		tile_offset = Vector2i(roundi(angle_to_next / (PI / 2)), 0)

	else:
		start_tile = Vector2i(0, 2)
		tile_offset = Vector2i(roundi(fposmod(angle_from_prev + angle_difference(angle_to_next, angle_from_prev) / PI - 0.5, TAU) / (PI / 2)), 0)

	return start_tile + tile_offset


func positive_angle(start_point: Vector2, end_point: Vector2) -> float:
	return fposmod(start_point.angle_to_point(end_point), TAU)
