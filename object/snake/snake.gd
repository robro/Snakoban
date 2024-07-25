class_name Snake
extends Node2D

const color : Color = Color.FOREST_GREEN
const tile_size : int = 8
const slow_tick := 0.4
const fast_tick := 0.1
var body_part : PackedScene = preload("res://object/snake/body_part.tscn")
var head : BodyPart
var tail : BodyPart
var tick_timer := Timer.new()
var alive := true

signal died


func _ready() -> void:
	modulate = color
	tick_timer.one_shot = true
	add_child(tick_timer)


func _physics_process(_delta: float) -> void:
	if not alive:
		return

	if Input.is_action_just_pressed("up", true):
		move(Vector2.UP * tile_size)
		tick_timer.start(slow_tick)
		return

	if Input.is_action_just_pressed("down", true):
		move(Vector2.DOWN * tile_size)
		tick_timer.start(slow_tick)
		return

	if Input.is_action_just_pressed("left", true):
		move(Vector2.LEFT * tile_size)
		tick_timer.start(slow_tick)
		return

	if Input.is_action_just_pressed("right", true):
		move(Vector2.RIGHT * tile_size)
		tick_timer.start(slow_tick)
		return

	if tick_timer.is_stopped():
		if Input.is_action_pressed("up", true):
			move(Vector2.UP * tile_size)

		elif Input.is_action_pressed("down", true):
			move(Vector2.DOWN * tile_size)

		elif Input.is_action_pressed("left", true):
			move(Vector2.LEFT * tile_size)

		elif Input.is_action_pressed("right", true):
			move(Vector2.RIGHT * tile_size)

		tick_timer.start(fast_tick)


func move(offset: Vector2) -> bool:
	if head == null:
		return false

	var query := PhysicsRayQueryParameters2D.create(
		head.position,
		head.position + offset,
		15,
	)
	query.collide_with_areas = true
	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if result:
		var collider : Node2D = result["collider"]
		if (collider is TileMap or
			collider.get_parent() is BodyPart or
			collider.get_collision_layer_value(4) and not collider.move(offset)
		):
			return false

	head.update_position(head.position + offset)
	return true


func append_body_part(point: Vector2) -> void:
	var new_part := body_part.instantiate()
	call_deferred("add_child", new_part)
	new_part.connect("hurt", _on_bodyPart_hurt)
	new_part.position = point

	if tail:
		tail.next_part = new_part
		new_part.prev_part = tail
		tail.update_rotation()
		tail.update_animation()
		tail = new_part
	else:
		head = new_part
		tail = new_part
		head.collision.connect("area_entered", _on_mouth_entered)


func _on_mouth_entered(area: Area2D) -> void:
	if area is Food:
		append_body_part(tail.prev_pos)
		area.eat()


func _on_bodyPart_hurt() -> void:
	alive = false
	emit_signal("died")
