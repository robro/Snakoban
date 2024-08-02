class_name Laser
extends GridObject

@export var self_powered : bool
var beam_collider : Variant
var power_inputs : Array[Laser]
var power_outputs : Array[Laser]
@onready var beam : Beam = $Beam
@onready var animation_player : AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super._ready()
	pushable = true
	if self_powered:
		power_inputs.append(self)


func connect_to(lasers: Array[Laser]) -> Array[Laser]:
	if self_powered or lasers.is_empty():
		return []
	var new_inputs : Array[Laser] = []
	for laser in lasers:
		if not laser in power_inputs:
			power_inputs.append(laser)
			new_inputs.append(laser)
	if new_inputs:
		if beam_collider is Object and beam_collider.has_method("connect_to"):
			power_outputs.append_array(beam_collider.connect_to(new_inputs))
		update_beam()
	return new_inputs


func disconnect_from(lasers: Array[Laser]) -> void:
	if self_powered or lasers.is_empty():
		return
	var lost_inputs : Array[Laser] = []
	var lost_outputs : Array[Laser] = []
	for laser in lasers:
		if laser in power_inputs:
			lost_inputs.append(power_inputs.pop_at(power_inputs.find(laser)))
		if laser in power_outputs:
			lost_outputs.append(power_outputs.pop_at(power_outputs.find(laser)))
	if lost_inputs:
		if beam_collider is Object and beam_collider.has_method("disconnect_from"):
			beam_collider.disconnect_from(lost_outputs)
		update_beam()


func update_beam() -> void:
	if power_inputs.is_empty():
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

	if is_same(cell, beam_collider):
		return
	var prev_collider : Variant = beam_collider
	beam_collider = cell
	if prev_collider is Object and prev_collider.has_method("disconnect_from"):
		prev_collider.disconnect_from(power_outputs)
		power_outputs.clear()
	if beam_collider is Object and beam_collider.has_method("connect_to"):
		power_outputs.append_array(beam_collider.connect_to(power_inputs))


func _on_grid_updated() -> void:
	update_beam()
