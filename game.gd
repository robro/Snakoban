extends Node2D

@export var grid : TileMap

var snake: Array[Vector2] = [
	Vector2(4, 3),
	Vector2(4, 2),
	Vector2(4, 1),
	Vector2(3, 1),
	Vector2(2, 1),
	Vector2(2, 0),
	Vector2(1, 0),
	Vector2(0, 0),
]
var tail_pos := snake[-1]


func _ready() -> void:
	assert(grid is TileMap)
	assert(snake.size() >= 2)


func _input(event: InputEvent) -> void:
	var facing = Vector2.from_angle(angle(snake[1], snake[0])).round()

	if event.is_action_pressed("up") and facing != Vector2.DOWN:
		move(Vector2.UP)
	elif event.is_action_pressed("down") and facing != Vector2.UP:
		move(Vector2.DOWN)
	elif event.is_action_pressed("left") and facing != Vector2.RIGHT:
		move(Vector2.LEFT)
	elif event.is_action_pressed("right") and facing != Vector2.LEFT:
		move(Vector2.RIGHT)


func move(offset: Vector2) -> void:
	tail_pos = snake.pop_back()
	snake.insert(0, snake[0] + offset)
	queue_redraw()


func _draw() -> void:
	grid.clear()
	for i in snake.size():
		grid.set_cell(0, snake[i], 1, get_snake_tile(i))


func angle(a: Vector2, b: Vector2) -> float:
	return fposmod(a.angle_to_point(b), TAU)


func get_snake_tile(i: int) -> Vector2i:
	var start_tile := Vector2i.ZERO
	var tile_offset := Vector2i.ZERO
	var angle_to_next := 0.0
	var angle_to_prev := 0.0

	if i - 1 >= 0:
		angle_to_prev = angle(snake[i - 1], snake[i])

	if i + 1 < snake.size():
		angle_to_next = angle(snake[i], snake[i + 1])

	if i == 0:
		start_tile = Vector2i.ZERO
		tile_offset = Vector2i(roundi(angle_to_next / (PI / 2)), 0)

	elif i == snake.size() - 1:
		start_tile = Vector2i(4, 1)
		tile_offset = Vector2i(roundi(angle_to_prev / (PI / 2)), 0)

	elif angle_to_next == angle_to_prev:
		start_tile = Vector2i(4, 0)
		tile_offset = Vector2i(roundi(angle_to_next / (PI / 2)), 0)

	else:
		start_tile = Vector2i(0, 1)
		tile_offset = Vector2i(
			roundi(fposmod(angle_to_prev + round((angle_difference(angle_to_next, angle_to_prev) - PI / 2) / PI), TAU) / (PI / 2)),
			0,
		)

	return start_tile + tile_offset
