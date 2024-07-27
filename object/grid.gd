class_name Grid
extends Resource

@export var cols := 16
@export var rows := 16
@export var cell_size := 8
var cells : Array[Array]
var shape : Rect2i

signal updated


func _init() -> void:
	shape = Rect2i(0, 0, cols, rows)
	cells.resize(rows)
	for row in cells:
		row.resize(cols)


func clear() -> void:
	for y in cells.size():
		for x in cells[y].size():
			cells[y][x] = null


func get_cell(coord: Vector2i) -> Variant:
	if shape.has_point(coord):
		return cells[coord.y][coord.x]
	return false


func set_cell(coord: Vector2i, value: Variant) -> bool:
	if shape.has_point(coord):
		cells[coord.y][coord.x] = value
		return true
	return false


func print() -> void:
	for row in cells:
		print(row)
