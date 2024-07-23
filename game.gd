extends Node2D

@onready var grid: TileMap = $Grid
@onready var state_chart: StateChart = $StateChart

var snake : Snake
var food := preload("res://object/food/food.tscn")
var box := preload("res://object/box/box.tscn")
var objects : Array[Node]
var flash_timer := Timer.new()
var reset_timer := Timer.new()
const tile_size := 8

enum Layer {
	SPRITES,
	WALLS,
}


func _ready() -> void:
	var sprite_positions := grid.get_used_cells(Layer.SPRITES)

	snake = Snake.new(sprite_positions.filter(
		func(p: Vector2i) -> bool:
			return grid.get_cell_atlas_coords(Layer.SPRITES, p) == Vector2i(0, 0)
	))
	add_child(snake)

	for point : Vector2i in sprite_positions.filter(
		func(p: Vector2i) -> bool:
			return grid.get_cell_atlas_coords(Layer.SPRITES, p) == Vector2i(2, 0)
	):
		var new_food : Food = food.instantiate()
		new_food.position = point * tile_size + Vector2i.ONE * tile_size / 2
		add_child(new_food)

	for point : Vector2i in sprite_positions.filter(
		func(p: Vector2i) -> bool:
			return grid.get_cell_atlas_coords(Layer.SPRITES, p) == Vector2i(1, 0)
	):
		var new_box : Box = box.instantiate()
		new_box.position = point * tile_size + Vector2i.ONE * tile_size / 2
		add_child(new_box)

	# for point in grid.get_used_cells_by_id(Layer.DYNAMIC, Id.BOX):
	# 	objects.append(Box.new(
	# 		point,
	# 		Id.BOX,
	# 		grid.get_cell_atlas_coords(Layer.DYNAMIC, point)
	# 	))

	# for point in grid.get_used_cells_by_id(Layer.DYNAMIC, Id.LASER):
	# 	var atlas_coord := grid.get_cell_atlas_coords(Layer.DYNAMIC, point)
	# 	if atlas_coord.y == 0:
	# 		objects.append(Emitter.new(point, Id.LASER, atlas_coord.x))
	# 	elif atlas_coord.y == 1:
	# 		objects.append(Relay.new(point, Id.LASER, atlas_coord.x))
	# 	else:
	# 		assert(false, "invalid atlas coordinate")

	$StateChart/Root/Lose.connect("state_entered", _on_lose_state_entered)
	$StateChart/Root/Win.connect("state_entered", _on_win_state_entered)
	grid.clear_layer(Layer.SPRITES)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()


func _on_lose_state_entered() -> void:
	flash_timer.wait_time = 0.1
	flash_timer.autostart = true
	flash_timer.connect("timeout", _on_lose_timer_timeout)
	add_child(flash_timer)

	reset_timer.wait_time = 1.0
	reset_timer.autostart = true
	reset_timer.connect("timeout", _on_reset_timer_timeout)
	add_child(reset_timer)

	# snake.queue_free()


func _on_lose_timer_timeout() -> void:
	pass
	# grid.set_layer_enabled(
	# 	Layer.SNAKE,
	# 	false if grid.is_layer_enabled(Layer.SNAKE) else true
	# )


func _on_win_state_entered() -> void:
	flash_timer.wait_time = 0.1
	flash_timer.autostart = true
	# flash_timer.connect("timeout", _on_win_timer_timeout)
	add_child(flash_timer)

	reset_timer.wait_time = 1.0
	reset_timer.autostart = true
	reset_timer.connect("timeout", _on_reset_timer_timeout)
	add_child(reset_timer)

	# snake.queue_free()


# func _on_win_timer_timeout() -> void:
# 	grid.set_layer_modulate(
# 		Layer.SNAKE,
# 		snake_color
# 			if grid.get_layer_modulate(Layer.SNAKE) == Color.WHITE
# 			else Color.WHITE
# 	)


func _on_reset_timer_timeout() -> void:
	get_tree().reload_current_scene()
