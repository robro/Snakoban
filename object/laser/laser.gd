class_name Laser
extends GridObject

@export var powered_color : Color
@export var self_powered : bool
var beam_collider : Variant
var connected_to : Dictionary
@onready var beam : Beam = $Beam


func _ready() -> void:
	super._ready()
	pushable = true
	if self_powered:
		connected_to[self] = null
	update_beam()


func connect_to(objects: Dictionary) -> void:
	if self_powered:
		return
	var connect_count := connected_to.size()
	for obj : Object in objects:
		connected_to[obj] = null
	if connected_to.size() > connect_count:
		update_beam()


func disconnect_from(objects: Dictionary) -> void:
	if self_powered:
		return
	var connect_count := connected_to.size()
	for obj : Object in objects:
		connected_to.erase(obj)
	if connected_to.size() < connect_count:
		if beam_collider is Object and beam_collider.has_method("disconnect_from"):
			beam_collider.disconnect_from(objects)
		update_beam()


func update_beam() -> void:
	if beam_collider is Object and beam_collider.has_method("disconnect_from"):
		beam_collider.disconnect_from(connected_to)
	beam_collider = null
	if connected_to.is_empty():
		beam.beam_texture.size.x = 0
		modulate = color
		return

	var beam_size := 0
	var direction := Vector2i(Vector2.from_angle(rotation))
	var cell : Variant = null
	while cell == null:
		cell = grid.get_cell(grid_coord + direction * (beam_size + 1))
		if cell:
			break
		beam_size += 1
	if cell is Object and cell.has_method("connect_to"):
		cell.connect_to(connected_to)
	beam_collider = cell
	beam.beam_texture.size.x = beam_size * grid.cell_size
	modulate = powered_color


func _on_grid_updated() -> void:
	if self_powered:
		update_beam()
