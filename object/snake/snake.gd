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
	tick_timer.one_shot = true
	add_child(tick_timer)

	head.collision.connect("area_entered", _on_mouth_entered)
	modulate = color


func _input(event: InputEvent) -> void:
	if tick_timer.is_stopped():
		handle_input(event)
		tick_timer.start(fast_tick)
		return

	if event.is_echo():
		return

	handle_input(event)
	tick_timer.start(slow_tick)


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("up", true):
		move(Vector2.UP * tile_size)
		return

	if event.is_action_pressed("down", true):
		move(Vector2.DOWN * tile_size)
		return

	if event.is_action_pressed("left", true):
		move(Vector2.LEFT * tile_size)
		return

	if event.is_action_pressed("right", true):
		move(Vector2.RIGHT * tile_size)
		return


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
