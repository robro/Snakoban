class_name Snake
extends Node2D

var body_part : PackedScene = preload("res://object/snake/body_part.tscn")
var head : BodyPart
var tail_point : Vector2
var auto_move_timer := Timer.new()
const unit_size : int = 8

signal want_move_to(point: Vector2i, direction: Vector2i)


func _init(points: Array[Vector2i]) -> void:
	var prev_part : BodyPart
	for point in points:
		var new_part : BodyPart = body_part.instantiate()
		add_child(new_part)
		new_part.position = point * unit_size
		if prev_part:
			prev_part.facing = new_part.position.direction_to(prev_part.position)
			new_part.facing = prev_part.facing
			prev_part.next_part = new_part
			new_part.prev_part = prev_part
		else:
			head = new_part

		prev_part = new_part


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
	if Input.is_action_pressed("up") and head.facing != Vector2.DOWN:
		try_move(Vector2.UP)

	elif Input.is_action_pressed("down") and head.facing != Vector2.UP:
		try_move(Vector2.DOWN)

	elif Input.is_action_pressed("left") and head.facing != Vector2.RIGHT:
		try_move(Vector2.LEFT)

	elif Input.is_action_pressed("right") and head.facing != Vector2.LEFT:
		try_move(Vector2.RIGHT)


func try_move(direction: Vector2) -> void:
	var collision := head.move_and_collide(direction * unit_size, true)
	if not collision:
		head.update_position(direction, head.position + direction * unit_size)
	# else:
	# 	print(collision.get_collider())


# func move_to(point: Vector2i) -> void:
# 	tail_point = body.pop_back()
# 	body.insert(0, point)


# func grow() -> void:
# 	body.append(tail_point)
