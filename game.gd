extends Node2D

@export var grid : TileMap
@export var snake_size := 5
@export var start_facing := Direction.RIGHT

var snake : Array[Vector2i]
var boxes : Array[Vector2i]
var tail_pos : Vector2i
var facing : Vector2i:
	get:
		return Vector2.from_angle(angle(snake[1], snake[0])).round()

enum Layer {
	OBJECTS,
	WALLS,
}

enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

const offsets = {
	Direction.UP: Vector2i.UP,
	Direction.DOWN: Vector2i.DOWN,
	Direction.LEFT: Vector2i.LEFT,
	Direction.RIGHT: Vector2i.RIGHT,
}


func _ready() -> void:
	assert(grid is TileMap)
	assert(snake_size > 1)

	for i in snake_size:
		snake.append(grid.get_used_cells_by_id(Layer.OBJECTS, 1)[0] + offsets[start_facing] * -i)

	boxes.append_array(grid.get_used_cells_by_id(Layer.OBJECTS, 2))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up") and facing != Vector2i.DOWN:
		try_move(Vector2i.UP)
	elif event.is_action_pressed("down") and facing != Vector2i.UP:
		try_move(Vector2i.DOWN)
	elif event.is_action_pressed("left") and facing != Vector2i.RIGHT:
		try_move(Vector2i.LEFT)
	elif event.is_action_pressed("right") and facing != Vector2i.LEFT:
		try_move(Vector2i.RIGHT)


func try_move(direction: Vector2i) -> void:
	for pos in snake:
		if snake[0] + direction == pos:
			return

	for i in boxes.size():
		if snake[0] + direction == boxes[i]:
			if (grid.get_cell_tile_data(Layer.OBJECTS, boxes[i] + direction) == null):
				boxes[i] += direction
			else:
				return

	tail_pos = snake.pop_back()
	snake.insert(0, snake[0] + direction)
	queue_redraw()


func _draw() -> void:
	grid.clear()
	for i in snake.size():
		grid.set_cell(Layer.OBJECTS, snake[i], 1, get_snake_tile(i))

	for i in boxes.size():
		grid.set_cell(Layer.OBJECTS, boxes[i], 2, Vector2i.ZERO)


func get_snake_tile(i: int) -> Vector2i:
	var start_tile := Vector2i.ZERO
	var tile_offset := Vector2i.ZERO
	var angle_to_next := 0.0
	var angle_from_prev := 0.0

	if i - 1 >= 0:
		angle_from_prev = angle(snake[i - 1], snake[i])

	if i + 1 < snake.size():
		angle_to_next = angle(snake[i], snake[i + 1])

	if i == 0:
		start_tile = Vector2i.ZERO
		tile_offset = Vector2i(roundi(angle_to_next / (PI / 2)), 0)

	elif i == snake.size() - 1:
		start_tile = Vector2i(0, 3)
		tile_offset = Vector2i(roundi(angle_from_prev / (PI / 2)), 0)

	elif angle_to_next == angle_from_prev:
		start_tile = Vector2i(0, 1)
		tile_offset = Vector2i(roundi(angle_to_next / (PI / 2)), 0)

	else:
		start_tile = Vector2i(0, 2)
		tile_offset = Vector2i(roundi(fposmod(angle_from_prev + angle_difference(angle_to_next, angle_from_prev) / PI - 0.5, TAU) / (PI / 2)), 0)

	return start_tile + tile_offset


func angle(a: Vector2, b: Vector2) -> float:
	return fposmod(a.angle_to_point(b), TAU)
