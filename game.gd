extends Node2D

@export var grid: TileMap

var snake: Snake
var boxes: Array[Vector2i]
var tail_pos: Vector2i

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

	snake = Snake.new(grid.get_used_cells(Layer.SNAKE))
	snake.connect("want_move_to", _on_snake_want_move_to)
	add_child(snake)
	boxes.append_array(grid.get_used_cells(Layer.MOVEABLE))


func _on_snake_want_move_to(point: Vector2i, direction: Vector2i) -> void:
	if grid.get_cell_tile_data(Layer.WALLS, point) != null:
		return


	for i in boxes.size():
		if point == boxes[i]:
			var box_point := point + direction
			if (grid.get_cell_tile_data(Layer.SNAKE, box_point) == null and
				grid.get_cell_tile_data(Layer.MOVEABLE, box_point) == null and
				grid.get_cell_tile_data(Layer.LASER, box_point) == null and
				grid.get_cell_tile_data(Layer.WALLS, box_point) == null
			):
				boxes[i] = box_point
			else:
				return

	snake.move_to(point)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()


func _draw() -> void:
	grid.clear_layer(Layer.SNAKE)
	grid.clear_layer(Layer.MOVEABLE)
	grid.clear_layer(Layer.DEATH)

	for i in snake.points.size():
		grid.set_cell(Layer.SNAKE, snake.points[i], 1, snake.get_tile(i))

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

	for death_pos in grid.get_used_cells(Layer.DEATH):
		if death_pos in snake.points:
			get_tree().reload_current_scene()
			return
