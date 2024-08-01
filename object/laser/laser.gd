class_name Laser
extends GridObject

@export var self_powered : bool
var beam_collider : Variant
var power_received : Array[Laser]
var power_relayed : Array[Laser]
@onready var beam : Beam = $Beam
@onready var animation_player : AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super._ready()
	pushable = true
	if self_powered:
		power_received.append(self)


func connect_to(lasers: Array[Laser]) -> Array[Laser]:
	if self_powered or lasers.is_empty():
		return []
	var new_power : Array[Laser] = []
	for laser in lasers:
		if not laser in power_received:
			power_received.append(laser)
			new_power.append(laser)
	if new_power:
		if beam_collider is Object and beam_collider.has_method("connect_to"):
			power_relayed.append_array(beam_collider.connect_to(new_power))
		update_beam()
	return new_power


func disconnect_from(lasers: Array[Laser]) -> void:
	if self_powered or lasers.is_empty():
		return
	var lost_power : Array[Laser] = []
	var lost_relays : Array[Laser] = []
	for laser in lasers:
		if laser in power_received:
			power_received.erase(laser)
			lost_power.append(laser)
		if laser in power_relayed:
			power_relayed.erase(laser)
			lost_relays.append(laser)
	if lost_power:
		if beam_collider is Object and beam_collider.has_method("disconnect_from"):
			beam_collider.disconnect_from(lost_relays)
		update_beam()


func update_beam() -> void:
	if power_received.is_empty():
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
		var prev_collider : Variant = beam_collider
		beam_collider = cell
		if prev_collider is Object and prev_collider.has_method("disconnect_from"):
			prev_collider.disconnect_from(power_relayed)
			power_relayed.clear()
		if beam_collider is Object and beam_collider.has_method("connect_to"):
			power_relayed.append_array(beam_collider.connect_to(power_received))


func _on_grid_updated() -> void:
	update_beam()
