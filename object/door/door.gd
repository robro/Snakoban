class_name Door
extends GridObject

var is_open := false
@onready var animation_player : AnimationPlayer = $AnimationPlayer


func open() -> void:
	is_open = true
	if is_same(grid.get_cell(grid_coord), self):
		animation_player.play("open")
		grid.set_cell(grid_coord, null)
		grid.updated.emit()


func close() -> void:
	is_open = false
	if is_same(grid.get_cell(grid_coord), null):
		animation_player.play("close")
		grid.set_cell(grid_coord, self)
		grid.updated.emit()


func _on_grid_updated() -> void:
	if is_open:
		open()
		visible = true if is_same(grid.get_cell(grid_coord), null) else false
	else:
		close()
		visible = true if is_same(grid.get_cell(grid_coord), self) else false
