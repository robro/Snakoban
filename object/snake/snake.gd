class_name Snake
extends Node2D

const color : Color = Color.FOREST_GREEN
const tile_size : int = 8
const slow_tick := 0.4
const fast_tick := 0.1
var tick_timer := Timer.new()
var alive := true
var grid : Grid = preload("res://object/grid.tres")
var body_part : PackedScene = preload("res://object/snake/body_part.tscn")
var parts : Array[BodyPart]
var head : BodyPart :
	get:
		if parts.is_empty():
			return null
		return parts[0]

var tail : BodyPart :
	get:
		if parts.is_empty():
			return null
		return parts[-1]

signal died


func _ready() -> void:
	modulate = color
	tick_timer.one_shot = true
	add_child(tick_timer)


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("up", true):
		move(Vector2.UP)
		tick_timer.start(slow_tick)
		return

	if Input.is_action_just_pressed("down", true):
		move(Vector2.DOWN)
		tick_timer.start(slow_tick)
		return

	if Input.is_action_just_pressed("left", true):
		move(Vector2.LEFT)
		tick_timer.start(slow_tick)
		return

	if Input.is_action_just_pressed("right", true):
		move(Vector2.RIGHT)
		tick_timer.start(slow_tick)
		return

	if tick_timer.is_stopped():
		if Input.is_action_pressed("up", true):
			move(Vector2.UP)

		elif Input.is_action_pressed("down", true):
			move(Vector2.DOWN)

		elif Input.is_action_pressed("left", true):
			move(Vector2.LEFT)

		elif Input.is_action_pressed("right", true):
			move(Vector2.RIGHT)

		tick_timer.start(fast_tick)


func move(direction: Vector2i) -> bool:
	if not alive:
		return false
	if head == null:
		return false
	eat_food_at(head.grid_coord + direction)
	if not head.move(direction):
		return false
	head.update_animation()
	Events.move.emit()
	return true


func eat_food_at(coord: Vector2i) -> void:
	var cell : Variant = grid.get_cell(coord)
	if cell is Food:
		cell.eat()
		grid.set_cell(coord, null)
		if cell.edible:
			append_body_part(tail.prev_coord)
		else:
			died.emit()


func append_body_part(coord: Vector2) -> void:
	var new_part := body_part.instantiate()
	add_child.call_deferred(new_part)
	new_part.hurt.connect(_on_bodyPart_hurt)
	new_part.grid_coord = coord

	if not parts.is_empty():
		tail.next_part = new_part
		new_part.prev_part = tail

	parts.append(new_part)


func _on_bodyPart_hurt() -> void:
	died.emit()
