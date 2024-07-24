extends Node2D

@export var state_chart: StateChart
@export var win_state : StateChartState
@export var lose_state : StateChartState
@export var grid: TileMap

var snake : Snake
var food_count := 0
var flash_timer := Timer.new()
var reset_timer := Timer.new()
const tile_size := 8
const win_flash_tick := 0.1
const lose_flash_tick := 0.1
const reset_wait_time := 1.0

enum Layer {
	SNAKE,
	SPRITE,
	STATIC,
}


func _ready() -> void:
	var snake_part_positions := grid.get_used_cells(Layer.SNAKE)
	var sprite_positions := grid.get_used_cells(Layer.SPRITE)

	snake = Snake.new(snake_part_positions)
	snake.connect("died", _on_snake_died)
	add_child(snake)

	for point in sprite_positions:
		var tile_data := grid.get_cell_tile_data(Layer.SPRITE, point)
		var rotation_index : int = tile_data.get_custom_data("RotationIndex")
		var scene_path : String = tile_data.get_custom_data("ScenePath")
		var packed_scene : PackedScene = load(scene_path)
		var scene_instance : Node2D = packed_scene.instantiate()
		add_child(scene_instance)
		scene_instance.position = point * tile_size + Vector2i.ONE * tile_size / 2
		scene_instance.rotation = rotation_index * (PI / 2)
		if scene_instance is Food:
			food_count += 1
			scene_instance.connect("eaten", _on_food_eaten)

	assert(food_count > 0, "scene must have food")

	win_state.connect("state_entered", _on_win_state_entered)
	lose_state.connect("state_entered", _on_lose_state_entered)
	grid.clear_layer(Layer.SNAKE)
	grid.clear_layer(Layer.SPRITE)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()


func _on_snake_died() -> void:
	state_chart.send_event("lost")


func _on_lose_state_entered() -> void:
	flash_timer.wait_time = lose_flash_tick
	flash_timer.autostart = true
	flash_timer.connect("timeout", _on_lose_timer_timeout)
	add_child(flash_timer)

	reset_timer.wait_time = reset_wait_time
	reset_timer.autostart = true
	reset_timer.connect("timeout", _on_reset_timer_timeout)
	add_child(reset_timer)

	snake.process_mode = Node.PROCESS_MODE_DISABLED


func _on_lose_timer_timeout() -> void:
	snake.visible = false if snake.visible else true


func _on_win_state_entered() -> void:
	flash_timer.wait_time = win_flash_tick
	flash_timer.autostart = true
	flash_timer.connect("timeout", _on_win_timer_timeout)
	add_child(flash_timer)

	reset_timer.wait_time = reset_wait_time
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
