extends Node2D

@onready var state_chart : StateChart = %"Level State"
@onready var win_state : StateChartState = %Win
@onready var lose_state : StateChartState = %Lose
@onready var level_map : TileMap = %"Level Map"
@onready var sprites : Node = $Sprites

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

	for node in sprites.get_children():
		if node is Food:
			food_count += 1
			node.eaten.connect(_on_food_eaten)

	assert(snake.length >= 2, "Invalid snake length: " + str(snake.length))
	assert(food_count >= 1, "Level must have food!")

	Events.move.connect(_on_events_move)
	Events.push.connect(_on_events_push)
	Stats.moves = 0
	Stats.pushes = 0
	Events.move_count_updated.emit()
	Events.push_count_updated.emit()
	Events.level_num_updated.emit()
	grid.updated.emit()


func _on_events_move() -> void:
	Stats.moves += 1
	Events.move_count_updated.emit()


func _on_events_push() -> void:
	Stats.pushes += 1
	Events.push_count_updated.emit()


func _on_snake_died() -> void:
	Events.lose.emit()


func _on_food_eaten() -> void:
	food_count -= 1
	assert(food_count >= 0, "Can't have negative food!")
	if food_count == 0 and snake.alive:
		snake.win()
		Events.win.emit()
