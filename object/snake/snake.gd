class_name Snake
extends Node2D

const color : Color = Color.FOREST_GREEN
const tile_size : int = 8
var body_part : PackedScene = preload("res://object/snake/body_part.tscn")
var head : BodyPart
var tail : BodyPart
var auto_move_timer := Timer.new()


func _init(points: Array[Vector2i]) -> void:
	assert(points.size() >= 2, "snake must have at least two segments")
	var curr_part : BodyPart
	var prev_part : BodyPart

	for point in points:
		curr_part = body_part.instantiate()
		curr_part.position = point * tile_size + Vector2i.ONE * tile_size / 2
		if prev_part:
			prev_part.next_part = curr_part
			curr_part.prev_part = prev_part
		else:
			head = curr_part

		add_child(curr_part)
		prev_part = curr_part

	tail = curr_part


func _ready() -> void:
	auto_move_timer.wait_time = 0.5
	auto_move_timer.one_shot = false
	auto_move_timer.connect("timeout", _on_autoMoveTimer_timeout)
	add_child(auto_move_timer)

	head.collision.connect("area_entered", _on_mouth_entered)
	modulate = color


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
	if Input.is_action_pressed("up"):
		try_move(Vector2.UP)

	elif Input.is_action_pressed("down"):
		try_move(Vector2.DOWN)

	elif Input.is_action_pressed("left"):
		try_move(Vector2.LEFT)

	elif Input.is_action_pressed("right"):
		try_move(Vector2.RIGHT)


func try_move(direction: Vector2) -> void:
	var query := PhysicsRayQueryParameters2D.create(
		head.position,
		head.position + direction * tile_size,
		3,
	)
	query.collide_with_areas = true
	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if not result:
		head.update_position(head.position + direction * tile_size)
	# else:
	# 	print(result)


func _on_mouth_entered(area: Area2D) -> void:
	if area is Food:
		area.queue_free()
		var new_tail : BodyPart = body_part.instantiate()
		tail.next_part = new_tail
		new_tail.prev_part = tail
		new_tail.position = tail.prev_pos
		tail = new_tail
		call_deferred("add_child", new_tail)
