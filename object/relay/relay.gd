class_name Relay
extends GridObject

@export var powered_color := Color.PURPLE
var beam_collider : Variant
var power_sources : Array[Laser]
@onready var beam : Beam = $Beam


func _ready() -> void:
	super._ready()
	pushable = true
	power_sources.clear()
	update_beam()


func power_on() -> void:
	modulate = powered_color
	update_beam()


func power_off() -> void:
	update_beam()


func connect_to(_power_sources: Array[Laser]) -> void:
	var connected := false
	for laser in _power_sources:
		if not laser in power_sources:
			power_sources.append(laser)
			connected = true
	if connected:
		power_on()


func disconnect_from(_power_sources: Array[Laser]) -> void:
	var disconnected := false
	for laser in _power_sources:
		var laser_idx := power_sources.find(laser)
		if laser_idx >= 0:
			power_sources.remove_at(laser_idx)
			disconnected = true
	if beam_collider is Relay and disconnected:
		beam_collider.disconnect_from(_power_sources)
	elif beam_collider is Food:
		beam_collider.edible = true
	if power_sources.is_empty():
		power_off()


func update_beam() -> void:
	beam_collider = null
	if power_sources.is_empty():
		beam.beam_texture.size.x = 0
		return

	var beam_size := 0
	var direction := Vector2i(Vector2.from_angle(rotation))
	var cell : Variant = null
	while cell == null:
		cell = grid.get_cell(grid_coord + direction * (beam_size + 1))
		if cell:
			break
		beam_size += 1
	if cell is Food:
		cell.edible = false
	elif cell is BodyPart:
		cell.hurt.emit()
	elif cell is Relay:
		cell.connect_to(power_sources)
	beam_collider = cell
	beam.beam_texture.size.x = beam_size * grid.cell_size
