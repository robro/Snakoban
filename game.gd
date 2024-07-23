extends Node2D

@onready var grid: TileMap = $Grid
@onready var state_chart: StateChart = $StateChart

var snake : Snake
var food := preload("res://object/food/food.tscn")
var box := preload("res://object/box/box.tscn")
var laser := preload("res://object/laser/laser.tscn")
var food_count : int = 0
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
		new_food.connect("eaten", _on_food_eaten)
		food_count += 1
		add_child(new_food)

	for point : Vector2i in sprite_positions.filter(
		func(p: Vector2i) -> bool:
			return grid.get_cell_atlas_coords(Layer.SPRITES, p) == Vector2i(1, 0)
	):
		var new_box : Box = box.instantiate()
		new_box.position = point * tile_size + Vector2i.ONE * tile_size / 2
		add_child(new_box)

	for point : Vector2i in sprite_positions.filter(
		func(p: Vector2i) -> bool:
			return Rect2i(
				Vector2i(0, 1),
				Vector2i(4, 2),
			).has_point(grid.get_cell_atlas_coords(Layer.SPRITES, p))
	):
		var new_laser : Laser = laser.instantiate()
		new_laser.position = point * tile_size + Vector2i.ONE * tile_size / 2
		new_laser.rotation += grid.get_cell_atlas_coords(Layer.SPRITES, point).x * (PI / 2)
		if grid.get_cell_atlas_coords(Layer.SPRITES, point).y == 2:
			new_laser.emitter = false
		add_child(new_laser)

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

	snake.process_mode = Node.PROCESS_MODE_DISABLED


func _on_lose_timer_timeout() -> void:
	snake.visible = false if snake.visible else true


func _on_win_state_entered() -> void:
	flash_timer.wait_time = 0.1
	flash_timer.autostart = true
	flash_timer.connect("timeout", _on_win_timer_timeout)
	add_child(flash_timer)

	reset_timer.wait_time = 1.0
	reset_timer.autostart = true
	reset_timer.connect("timeout", _on_reset_timer_timeout)
	add_child(reset_timer)

	snake.process_mode = Node.PROCESS_MODE_DISABLED


func _on_win_timer_timeout() -> void:
	snake.modulate = Color.WHITE if snake.modulate == snake.color else snake.color


func _on_reset_timer_timeout() -> void:
	get_tree().reload_current_scene()


func _on_food_eaten() -> void:
	food_count -= 1
	if food_count == 0:
		state_chart.send_event("won")
