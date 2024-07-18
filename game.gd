extends Node2D

@onready var grid: TileMap = $Grid
@onready var state_chart: StateChart = $StateChart

var snake: Snake
var snake_color: Color
var box_points: Array[Vector2i]
var tail_pos: Vector2i
var flash_timer := Timer.new()
var reset_timer := Timer.new()

enum Layer {
	SNAKE,
	SOLID,
	PERMEABLE,
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
	snake = Snake.new(grid.get_used_cells(Layer.SNAKE))
	snake.connect("want_move_to", _on_snake_want_move_to)
	add_child(snake)
	snake_color = grid.get_layer_modulate(Layer.SNAKE)
	box_points.append_array(grid.get_used_cells_by_id(Layer.SOLID, Id.BOX))
	$StateChart/Root/Lose.connect("state_entered", _on_lose_state_entered)
	$StateChart/Root/Win.connect("state_entered", _on_win_state_entered)


func _on_snake_want_move_to(point: Vector2i, direction: Vector2i) -> void:
	var world_point_id := grid.get_cell_source_id(Layer.SOLID, point)

	if world_point_id == Id.WALLS:
		return

	if world_point_id == Id.FOOD:
		grid.set_cell(Layer.SOLID, point)
		snake.grow()
	else:
		for i in box_points.size():
			if point == box_points[i]:
				var box_point := point + direction
				if (box_point in grid.get_used_cells(Layer.SOLID) or
					box_point in snake.points
				):
					return
				else:
					box_points[i] = box_point
					grid.set_cell(Layer.SOLID, point)
					grid.set_cell(Layer.SOLID, box_point, Id.BOX, Vector2i.ZERO)

	snake.move_to(point)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()


func _draw() -> void:
	grid.clear_layer(Layer.SNAKE)
	grid.clear_layer(Layer.PERMEABLE)

	for i in snake.points.size():
		grid.set_cell(Layer.SNAKE, snake.points[i], Id.SNAKE, snake.get_tile(i))

	for point in grid.get_used_cells_by_id(Layer.SOLID, Id.LASER):
		var direction := Vector2.from_angle(
			grid.get_cell_atlas_coords(Layer.SOLID, point).x * (PI / 2)
		)
		var beam_point := point + Vector2i(direction)
		while (grid.get_cell_tile_data(Layer.SOLID, beam_point) == null):
			grid.set_cell(Layer.PERMEABLE, beam_point, Id.LASER, Vector2i(0, 1))
			beam_point += Vector2i(direction)

	for death_point in grid.get_used_cells_by_id(Layer.PERMEABLE, Id.LASER):
		if death_point in snake.points:
			state_chart.send_event("lost")
			return

	if grid.get_used_cells_by_id(Layer.SOLID, Id.FOOD).size() == 0:
		state_chart.send_event("won")


func _on_lose_state_entered() -> void:
	flash_timer.wait_time = 0.1
	flash_timer.autostart = true
	flash_timer.connect("timeout", _on_lose_timer_timeout)
	add_child(flash_timer)

	reset_timer.wait_time = 1.0
	reset_timer.autostart = true
	reset_timer.connect("timeout", _on_reset_timer_timeout)
	add_child(reset_timer)

	snake.queue_free()


func _on_lose_timer_timeout() -> void:
	grid.set_layer_enabled(
		Layer.SNAKE,
		false if grid.is_layer_enabled(Layer.SNAKE) else true
	)


func _on_win_state_entered() -> void:
	flash_timer.wait_time = 0.1
	flash_timer.autostart = true
	flash_timer.connect("timeout", _on_win_timer_timeout)
	add_child(flash_timer)

	reset_timer.wait_time = 1.0
	reset_timer.autostart = true
	reset_timer.connect("timeout", _on_reset_timer_timeout)
	add_child(reset_timer)

	snake.queue_free()


func _on_win_timer_timeout() -> void:
	grid.set_layer_modulate(
		Layer.SNAKE,
		snake_color if grid.get_layer_modulate(Layer.SNAKE) == Color.WHITE else Color.WHITE
	)


func _on_reset_timer_timeout() -> void:
	get_tree().reload_current_scene()
