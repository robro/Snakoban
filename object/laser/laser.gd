class_name Laser
extends GridObject

@export var self_powered : bool
var beam_collider : Variant
var receiving : Array[Laser]
var sending : Array[Laser]
@onready var beam : Beam = $Beam
@onready var animation_player : AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super._ready()
	pushable = true
	if self_powered:
		receiving.append(self)


func connect_to(lasers: Array[Laser]) -> Array[Laser]:
	if self_powered:
		return []
	var connections : Array[Laser] = []
	for laser in lasers:
		if not laser in receiving:
			receiving.append(laser)
			connections.append(laser)
	if connections:
		if beam_collider is Object and beam_collider.has_method("connect_to"):
			sending.append_array(beam_collider.connect_to(connections))
		update_beam()
	return connections


func disconnect_from(lasers: Array[Laser]) -> Array[Laser]:
	if self_powered:
		return []
	var disconnections : Array[Laser] = []
	for laser in lasers:
		if laser in receiving:
			receiving.remove_at(receiving.find(laser))
			disconnections.append(laser)
	if disconnections:
		for laser in disconnections:
			if not laser in sending:
				disconnections.remove_at(disconnections.find(laser))
			else:
				sending.remove_at(sending.find(laser))
		if beam_collider is Object and beam_collider.has_method("disconnect_from"):
			beam_collider.disconnect_from(disconnections)
		update_beam()
	return disconnections


func update_beam() -> void:
	if receiving.is_empty():
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
			prev_collider.disconnect_from(sending)
			sending.clear()
		if beam_collider is Object and beam_collider.has_method("connect_to"):
			sending.append_array(beam_collider.connect_to(receiving))


func _on_grid_updated() -> void:
		update_beam()
