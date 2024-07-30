class_name Door
extends GridObject

@onready var animation_player : AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super._ready()
	animation_player.play("close")
	Events.switch_on.connect(_on_switch_on)
	Events.switch_off.connect(_on_switch_off)


func _on_switch_on() -> void:
	animation_player.play("open")
	grid.set_cell(grid_coord, null)


func _on_switch_off() -> void:
	animation_player.play("close")
	grid.set_cell(grid_coord, self)
