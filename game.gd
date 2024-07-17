extends Node2D

@export var grid: TileMap

var snake: Snake
var box_points: Array[Vector2i]
var tail_pos: Vector2i

enum Layer {
	DYNAMIC,
	STATIC,
}

enum Id {
	SNAKE,
	BOX,
	FOOD,
	WALLS,
	LASER,
}


func _ready() -> void:
	assert(grid is TileMap)

	# Snake tiles are sorted by the order they were drawn in
	# so draw them from head to tail
	snake = Snake.new(grid.get_used_cells_by_id(Layer.DYNAMIC, Id.SNAKE))
	snake.connect("want_move_to", _on_snake_want_move_to)
	add_child(snake)
	box_points.append_array(grid.get_used_cells_by_id(Layer.DYNAMIC, Id.BOX))


func _on_snake_want_move_to(point: Vector2i, direction: Vector2i) -> void:
	var static_point_id := grid.get_cell_source_id(Layer.STATIC, point)

	if static_point_id == Id.WALLS:
		return

	if static_point_id == Id.FOOD:
		grid.set_cell(Layer.STATIC, point)
		snake.grow()
	else:
		for i in box_points.size():
			if point == box_points[i]:
				var box_point := point + direction
				if (grid.get_cell_tile_data(Layer.STATIC, box_point) == null and
					not box_point in snake.points and
					not box_point in box_points
				):
					box_points[i] = box_point
				else:
					return

	snake.move_to(point)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()


func _draw() -> void:
	grid.clear_layer(Layer.DYNAMIC)

	for i in snake.points.size():
		grid.set_cell(Layer.DYNAMIC, snake.points[i], Id.SNAKE, snake.get_tile(i))

	for i in box_points.size():
		grid.set_cell(Layer.DYNAMIC, box_points[i], Id.BOX, Vector2i.ZERO)

	for point in grid.get_used_cells_by_id(Layer.STATIC, Id.LASER):
		var direction := Vector2.from_angle(
			grid.get_cell_atlas_coords(Layer.STATIC, point).x * (PI / 2)
		)
		var beam_point := point + Vector2i(direction)
		while (grid.get_cell_tile_data(Layer.STATIC, beam_point) == null):
			if beam_point in box_points:
				break
			grid.set_cell(Layer.DYNAMIC, beam_point, Id.LASER, Vector2i(0, 1))
			beam_point += Vector2i(direction)

	for death_point in grid.get_used_cells_by_id(Layer.DYNAMIC, Id.LASER):
		if death_point in snake.points:
			get_tree().reload_current_scene()
			return
