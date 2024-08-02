extends Node2D

@onready var state_chart : StateChart = %"Level State"
@onready var win_state : StateChartState = %Win
@onready var lose_state : StateChartState = %Lose
@onready var level_map : TileMap = %"Level Map"

var grid : Grid = preload("res://object/grid.tres")
var snake : Snake
var food_count := 0
var flash_timer := Timer.new()
const snake_scene : PackedScene = preload("res://object/snake/snake.tscn")
const reset_wait_time := 1.0

enum Layer {
	SNAKE,
	WALLS,
}

func _init() -> void:
	grid.clear()


func _ready() -> void:
	var wall_coords := level_map.get_used_cells(Layer.WALLS)
	for coord in wall_coords:
		grid.set_cell(coord, 1)

	var snake_coords := level_map.get_used_cells_by_id(Layer.SNAKE)
	level_map.clear_layer(Layer.SNAKE)
	snake = snake_scene.instantiate()
	snake.died.connect(_on_snake_died)
	for coord in snake_coords:
		snake.append_body_part(coord)
	add_child(snake)

	for food : Food in get_tree().get_nodes_in_group("food"):
		food_count += 1
		food.eaten.connect(_on_food_eaten)

	assert(snake.length >= 2, "Invalid snake length: " + str(snake.length))
	assert(food_count >= 1, "Level must have food!")

	win_state.state_entered.connect(_on_winState_entered)
	lose_state.state_entered.connect(_on_loseState_entered)
	grid.updated.emit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Reset"):
		get_tree().reload_current_scene()


func _on_snake_died() -> void:
	state_chart.send_event("lost")


func _on_food_eaten() -> void:
	food_count -= 1
	assert(food_count >= 0, "Can't have negative food!")
	if food_count == 0:
		state_chart.send_event.call_deferred("won")


func _on_loseState_entered() -> void:
	await get_tree().create_timer(reset_wait_time).timeout
	get_tree().reload_current_scene()


func _on_winState_entered() -> void:
	snake.win()
	await get_tree().create_timer(reset_wait_time).timeout
	Levels.curr_level_idx += 1
	Levels.curr_level_idx %= Levels.level_paths.size()
	get_tree().change_scene_to_file(Levels.level_paths[Levels.curr_level_idx])
