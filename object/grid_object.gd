class_name GridObject
extends Node2D

var default_color : Color
var pushable := false
var grid : Grid = preload("res://object/grid.tres")
var grid_coord : Vector2i :
	set(value):
		grid_coord = value
		position = (grid_coord * grid.cell_size) + (Vector2i.ONE * grid.cell_size / 2)


func _ready() -> void:
	default_color = modulate
	grid_coord = position / grid.cell_size
	grid.set_cell(grid_coord, self)


func move(to_coord: Vector2i, direction: Vector2i) -> bool:
	var to_cell : Variant = grid.get_cell(to_coord)
	if to_cell is bool and to_cell == true:
		return false
	if to_cell is GridObject:
		if to_cell.pushable:
			if not to_cell.move(to_coord + direction, direction):
				return false
		else:
			return false
	grid.set_cell(grid_coord, null)
	grid.set_cell(to_coord, self)
	grid_coord = to_coord
	return true
