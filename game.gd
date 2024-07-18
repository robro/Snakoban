extends Node2D

@onready var grid: TileMap = $Grid
@onready var state_chart: StateChart = $StateChart

var snake: Snake
var snake_color: Color
var boxes: Array[Box]
var lasers: Array[Laser]
var foods: Array[Food]
var flash_timer := Timer.new()
var reset_timer := Timer.new()

enum Layer {
	SNAKE,
	DYNAMIC,
	STATIC,
	H_BEAM,
	V_BEAM,
}

enum Id {
	SNAKE,
	BOX,
	FOOD,
	WALLS,
	LASER,
	BEAM,
}


func _ready() -> void:
	assert(grid is TileMap)

	# Snake tiles are sorted by the order they were drawn in
	# so draw them from head to tail
	snake_color = grid.get_layer_modulate(Layer.SNAKE)
	snake = Snake.new(grid.get_used_cells(Layer.SNAKE))
	snake.connect("want_move_to", _on_snake_want_move_to)
	add_child(snake)

	for point in grid.get_used_cells_by_id(Layer.DYNAMIC, Id.BOX):
		boxes.append(Box.new(point, grid.get_cell_atlas_coords(Layer.DYNAMIC, point)))

	for point in grid.get_used_cells_by_id(Layer.DYNAMIC, Id.LASER):
		lasers.append(Laser.new(point, grid.get_cell_atlas_coords(Layer.DYNAMIC, point)))

	for point in grid.get_used_cells_by_id(Layer.DYNAMIC, Id.FOOD):
		foods.append(Food.new(point, grid.get_cell_atlas_coords(Layer.DYNAMIC, point)))

	$StateChart/Root/Lose.connect("state_entered", _on_lose_state_entered)
	$StateChart/Root/Win.connect("state_entered", _on_win_state_entered)


func _on_snake_want_move_to(point: Vector2i, direction: Vector2i) -> void:
	if point in grid.get_used_cells(Layer.STATIC):
		return

	for i in foods.size():
		if point == foods[i].point:
			snake.grow()
			foods.remove_at(i)
			if foods.size() == 0:
				state_chart.send_event("won")
			break

	for i in boxes.size():
		if point == boxes[i].point:
			var box_move_point := point + direction
			if (box_move_point in grid.get_used_cells(Layer.DYNAMIC) or
				box_move_point in grid.get_used_cells(Layer.STATIC) or
				box_move_point in grid.get_used_cells(Layer.SNAKE)
			):
				return
			else:
				boxes[i].point = box_move_point

	for i in lasers.size():
		if point == lasers[i].point:
			var laser_move_point := point + direction
			if (laser_move_point in grid.get_used_cells(Layer.DYNAMIC) or
				laser_move_point in grid.get_used_cells(Layer.STATIC) or
				laser_move_point in grid.get_used_cells(Layer.SNAKE)
			):
				return
			else:
				lasers[i].point = laser_move_point

	snake.move_to(point)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()


func _draw() -> void:
	grid.clear_layer(Layer.SNAKE)
	grid.clear_layer(Layer.DYNAMIC)
	grid.clear_layer(Layer.H_BEAM)
	grid.clear_layer(Layer.V_BEAM)

	for i in snake.points.size():
		grid.set_cell(Layer.SNAKE, snake.points[i], Id.SNAKE, snake.get_tile(i))

	for food in foods:
		grid.set_cell(Layer.DYNAMIC, food.point, Id.FOOD, food.atlas_coord)

	for box in boxes:
		grid.set_cell(Layer.DYNAMIC, box.point, Id.BOX, box.atlas_coord)

	for laser in lasers:
		grid.set_cell(Layer.DYNAMIC, laser.point, Id.LASER, laser.atlas_coord)

	var lasers_to_emit: Array[Laser] = lasers.filter(func(l: Laser) -> bool: return l.active)
	var inactive_lasers: Array[Laser] = lasers.filter(func(l: Laser) -> bool: return not l.active)

	while lasers_to_emit.size() > 0:
		var laser: Laser = lasers_to_emit.pop_front()
		grid.set_cell(Layer.DYNAMIC, laser.point, Id.LASER, Vector2i(laser.atlas_x, 0))
		var beam_point := laser.point + laser.direction

		while (grid.get_cell_tile_data(Layer.STATIC, beam_point) == null):
			if beam_point in snake.points:
				state_chart.send_event("lost")

			if beam_point in grid.get_used_cells(Layer.DYNAMIC):
				break

			grid.set_cell(
				Layer.H_BEAM if is_horizontal(laser.direction) else Layer.V_BEAM,
				beam_point,
				Id.BEAM,
				Vector2i(0, 0) if is_horizontal(laser.direction) else Vector2i(2, 0)
			)
			beam_point += laser.direction

		for i in range(inactive_lasers.size() - 1, -1, -1):
			if beam_point == inactive_lasers[i].point:
				# inactive_lasers[i].active = true
				lasers_to_emit.append(inactive_lasers.pop_at(i))


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
		snake_color
			if grid.get_layer_modulate(Layer.SNAKE) == Color.WHITE
			else Color.WHITE
	)


func _on_reset_timer_timeout() -> void:
	get_tree().reload_current_scene()


func clear_cell(_grid: TileMap, _layer: int, _point: Vector2i) -> void:
	_grid.set_cell(_layer, _point)


func is_horizontal(direction: Vector2i) -> bool:
	return direction == Vector2i.RIGHT or direction == Vector2i.LEFT
