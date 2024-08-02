class_name Snake
extends Node2D

@export var slow_tick := 0.4
@export var fast_tick := 0.1

const actions := {
	"Up": Vector2i.UP,
	"Down": Vector2i.DOWN,
	"Left": Vector2i.LEFT,
	"Right": Vector2i.RIGHT,
}
var event_stack : Array[String]
var move_timer := Timer.new()
var alive := true
var controlable := true
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
	move_timer.one_shot = true
	move_timer.timeout.connect(_on_moveTimer_timeout)
	add_child(move_timer)


func _unhandled_key_input(event: InputEvent) -> void:
	var event_action := event.as_text()
	if not event.is_echo() and event_action in actions:
		var last_action := "" if event_stack.is_empty() else event_stack[-1]
		if event.is_action_pressed(event_action):
			event_stack.append(event_action)

		elif event.is_action_released(event_action):
			var action_idx := event_stack.find(event_action)
			if action_idx >= 0:
				event_stack.remove_at(action_idx)

		if not event_stack.is_empty() and last_action != event_stack[-1]:
			move(actions[event_stack[-1]])
			move_timer.start(slow_tick)


func _on_moveTimer_timeout() -> void:
	if not event_stack.is_empty():
		move(actions[event_stack[-1]])
		move_timer.start(fast_tick)


func move(direction: Vector2i) -> void:
	if not controlable or parts.is_empty():
		return
	eat_food_at(head.grid_coord + direction)
	if not head.move(direction):
		return
	grid.updated.emit()


func eat_food_at(coord: Vector2i) -> void:
	var cell : Variant = grid.get_cell(coord)
	if not cell is Food:
		return
	cell.eat()
	grid.set_cell(coord, null)
	if not cell.edible:
		die()
		return
	append_body_part(tail.prev_coord)
	for part in parts:
		if not alive:
			return
		part.physical_anim.play("grow")
		if is_inside_tree():
			await get_tree().create_timer(0.05).timeout


func append_body_part(coord: Vector2) -> void:
	var new_part := body_part.instantiate()
	new_part.hurt.connect(_on_bodyPart_hurt)
	new_part.grid_coord = coord

	if not parts.is_empty():
		tail.next_part = new_part
		new_part.prev_part = tail

	parts.append(new_part)
	add_child(new_part)


func die() -> void:
	alive = false
	controlable = false
	died.emit()
	for part in parts:
		part.color_anim.play("dead")
		part.physical_anim.play("RESET")


func win() -> void:
	controlable = false
	for part in parts:
		part.color_anim.play("win")


func _on_bodyPart_hurt() -> void:
	die()
