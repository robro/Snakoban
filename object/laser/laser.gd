class_name Laser
extends GridObject

@export var self_powered : bool
var beam_collider : Variant
var powered_by : Dictionary
@onready var beam : Beam = $Beam
@onready var animation_player : AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super._ready()
	pushable = true
	if self_powered:
		powered_by[self] = null
	else:
		update_beam()


func connect_to(objects: Dictionary) -> void:
	if self_powered:
		return
	var powered_count := powered_by.size()
	for obj : Object in objects:
		powered_by[obj] = null
	if powered_by.size() > powered_count:
		update_beam()


func disconnect_from(objects: Dictionary) -> void:
	if self_powered:
		return
	var connect_count := powered_by.size()
	for obj : Object in objects:
		powered_by.erase(obj)
	if powered_by.size() < connect_count:
		if beam_collider is Object and beam_collider.has_method("disconnect_from"):
			beam_collider.disconnect_from(objects)
		update_beam()


func update_beam() -> void:
	if powered_by.is_empty():
		beam_collider = null
		beam.beam_texture.size.x = 0
		animation_player.play("idle")
		return

	var beam_size := 0
	var direction := Vector2i(Vector2.from_angle(rotation))
	var cell : Variant = null
	while cell == null:
		cell = grid.get_cell(grid_coord + direction * (beam_size + 1))
		if cell:
			break
		beam_size += 1

	beam.beam_texture.size.x = beam_size * grid.cell_size
	animation_player.play("powered")

	if not is_same(cell, beam_collider):
		if beam_collider is Object and beam_collider.has_method("disconnect_from"):
			beam_collider.disconnect_from(powered_by)
		beam_collider = cell
		if beam_collider is Object and beam_collider.has_method("connect_to"):
			beam_collider.connect_to(powered_by)


func _on_grid_updated() -> void:
		update_beam()
