class_name GridObject
extends Node2D

var pushable := false
var grid : Grid = preload("res://object/grid.tres")
var grid_coord : Vector2i :
	set(new_coord):
		grid_coord = new_coord
		position = (
			grid_coord * grid.cell_size +
			Vector2i.ONE * grid.cell_size / 2)


func _ready() -> void:
	grid.updated.connect(_on_grid_updated)
	grid_coord = (position / grid.cell_size).floor()
	grid.set_cell(grid_coord, self)


func move(direction: Vector2i) -> bool:
	if grid.get_cell(grid_coord + direction) != null:
		return false
	grid.set_cell(grid_coord + direction, self)
	grid.set_cell(grid_coord, null)
	grid_coord += direction
	if pushable:
		Events.push.emit()
	return true


func _on_grid_updated() -> void:
	pass
