extends Node2D

@export var grid : TileMap

var snake : Array[Vector2i]
var boxes : Array[Vector2i]
var tail_pos : Vector2i

enum Layer {
	SNAKE,
	MOVEABLE,
	WALLS,
	LASER,
	DEATH,
	GOAL,
}


func _ready() -> void:
	assert(grid is TileMap)

	snake.append_array(grid.get_used_cells(Layer.SNAKE))
	boxes.append_array(grid.get_used_cells(Layer.MOVEABLE))


func _input(event: InputEvent) -> void:
	var facing := Vector2i(Vector2.from_angle(angle(snake[1], snake[0])))

	if event.is_action_pressed("up") and facing != Vector2i.DOWN:
		try_move(Vector2i.UP)

	elif event.is_action_pressed("down") and facing != Vector2i.UP:
		try_move(Vector2i.DOWN)

	elif event.is_action_pressed("left") and facing != Vector2i.RIGHT:
		try_move(Vector2i.LEFT)

	elif event.is_action_pressed("right") and facing != Vector2i.LEFT:
		try_move(Vector2i.RIGHT)

	elif event.is_action_pressed("reset"):
		get_tree().reload_current_scene()


func try_move(direction: Vector2i) -> void:
	var try_pos := snake[0] + direction

	if grid.get_cell_tile_data(Layer.GOAL, try_pos) != null:
		get_tree().reload_current_scene()
		return

	if grid.get_cell_tile_data(Layer.WALLS, try_pos) != null:
		return

	for part_pos in snake:
		if try_pos == part_pos:
			return

	for i in boxes.size():
		if try_pos == boxes[i]:
			var try_box_pos := boxes[i] + direction
			if (grid.get_cell_tile_data(Layer.SNAKE, try_box_pos) == null and
				grid.get_cell_tile_data(Layer.MOVEABLE, try_box_pos) == null and
				grid.get_cell_tile_data(Layer.WALLS, try_box_pos) == null
			):
				boxes[i] += direction
			else:
				return

	tail_pos = snake.pop_back()
	snake.insert(0, try_pos)
	queue_redraw()


func _draw() -> void:
	grid.clear_layer(Layer.SNAKE)
	grid.clear_layer(Layer.MOVEABLE)
	grid.clear_layer(Layer.DEATH)

	for i in snake.size():
		grid.set_cell(Layer.SNAKE, snake[i], 1, get_snake_tile(i))

	for i in boxes.size():
		grid.set_cell(Layer.MOVEABLE, boxes[i], 2, Vector2i.ZERO)

	for pos in grid.get_used_cells(Layer.LASER):
		var direction := Vector2.from_angle(
			grid.get_cell_atlas_coords(Layer.LASER, pos).x * (PI / 2)
		)
		var try_pos := pos + Vector2i(direction)
		while (grid.get_cell_tile_data(Layer.WALLS, try_pos) == null and
			grid.get_cell_tile_data(Layer.MOVEABLE, try_pos) == null
		):
			grid.set_cell(Layer.DEATH, try_pos, 2, Vector2i(0, 2))
			try_pos += Vector2i(direction)

	for death_pos in grid.get_used_cells_by_id(Layer.DEATH):
		for snake_pos in snake:
			if snake_pos == death_pos:
				get_tree().reload_current_scene()
				return


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
