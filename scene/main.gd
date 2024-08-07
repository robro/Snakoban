extends Node2D

@export var reset_wait_time := 1.0
var controlable := true
@onready var level : Node2D
@onready var viewport : SubViewport = %"Game Viewport"


func _ready() -> void:
	Events.win.connect(_on_events_win)
	Events.lose.connect(_on_events_lose)
	load_level()


func load_level() -> void:
	if level is Node2D:
		level.free()
	level = load(Levels.level_paths[Levels.curr_level_idx]).instantiate()
	viewport.add_child(level)


func _on_events_win() -> void:
	controlable = false
	await get_tree().create_timer(reset_wait_time).timeout
	Levels.curr_level_idx += 1
	Levels.curr_level_idx %= Levels.level_paths.size()
	Stats.level_num = Levels.curr_level_idx + 1
	load_level()
	controlable = true


func _on_events_lose() -> void:
	controlable = false
	await get_tree().create_timer(reset_wait_time).timeout
	load_level()
	controlable = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Reset") and controlable:
		load_level()
