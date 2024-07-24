class_name Snake
extends Node2D

const color : Color = Color.FOREST_GREEN
const tile_size : int = 8
var body_part : PackedScene = preload("res://object/snake/body_part.tscn")
var head : BodyPart
var tail : BodyPart
var tick_timer := Timer.new()
const slow_tick := 0.4
const fast_tick := 0.1

signal died


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

		curr_part.connect("hurt", _on_bodyPart_hurt)
		add_child(curr_part)
		prev_part = curr_part

	tail = curr_part


func _ready() -> void:
	tick_timer.connect("timeout", _on_tickTimer_timeout)
	add_child(tick_timer)

	head.collision.connect("area_entered", _on_mouth_entered)
	modulate = color


func _physics_process(_delta: float) -> void:
	if (Input.is_action_just_pressed("up") or
		Input.is_action_just_pressed("down") or
		Input.is_action_just_pressed("left") or
		Input.is_action_just_pressed("right")
	):
		handle_input()
		tick_timer.wait_time = slow_tick
		tick_timer.start()


func _on_tickTimer_timeout() -> void:
	handle_input()
	tick_timer.wait_time = fast_tick
	tick_timer.start()


func handle_input() -> void:
	if Input.is_action_pressed("up"):
		move(Vector2.UP * tile_size)

	elif Input.is_action_pressed("down"):
		move(Vector2.DOWN * tile_size)

	elif Input.is_action_pressed("left"):
		move(Vector2.LEFT * tile_size)

	elif Input.is_action_pressed("right"):
		move(Vector2.RIGHT * tile_size)


func move(offset: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(
		head.position,
		head.position + offset,
		15,
	)
	query.collide_with_areas = true
	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if result:
		var collider : Node = result["collider"]
		if (collider is TileMap or
			collider.get_parent() is BodyPart or
			collider is Box and not collider.move(offset) or
			collider is Laser and not collider.move(offset)
		):
			return false

	head.update_position(head.position + offset)
	return true


func _on_mouth_entered(area: Area2D) -> void:
	if area is Food:
		area.eat()
		var new_tail : BodyPart = body_part.instantiate()
		tail.next_part = new_tail
		new_tail.prev_part = tail
		new_tail.position = tail.prev_pos
		tail = new_tail
		call_deferred("add_child", new_tail)


func _on_bodyPart_hurt() -> void:
	emit_signal("died")
