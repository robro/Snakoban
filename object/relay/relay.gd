class_name Relay
extends GridObject

@export var idle_color := Color.DIM_GRAY
@export var powered_color := Color.PURPLE
@export var beam : Beam
var powering : Relay
var power_sources : Array[Laser]


func _ready() -> void:
	super._ready()
	pushable = true
	modulate = idle_color
	power_sources.clear()


func power_on() -> void:
	modulate = powered_color
	update_beam()


func power_off() -> void:
	modulate = idle_color
	powering = null
	update_beam()


func connect_to(_power_sources: Array[Laser]) -> void:
	for laser in _power_sources:
		if not laser in power_sources:
			power_sources.append(laser)
			power_on()


func disconnect_from(_power_sources: Array[Laser]) -> void:
	var disconnected := false
	for laser in _power_sources:
		var laser_idx := power_sources.find(laser)
		if laser_idx >= 0:
			power_sources.remove_at(laser_idx)
			disconnected = true
	if powering is Relay and disconnected:
		powering.disconnect_from(_power_sources)
	if power_sources.is_empty():
		power_off()


func update_beam() -> void:
	if power_sources.is_empty():
		beam.beam_texture.size.x = 0
		return

	var beam_size := 0
	var direction := Vector2i(Vector2.from_angle(rotation))
	var curr_cell : Variant
	while curr_cell == null:
		curr_cell = grid.get_cell(grid_coord + direction * (beam_size + 1))
		if curr_cell:
			break
		beam_size += 1
	if curr_cell is BodyPart:
		curr_cell.hurt.emit()
	elif curr_cell is Relay:
		curr_cell.connect_to(power_sources)
		powering = curr_cell
	beam.beam_texture.size.x = beam_size * grid.cell_size
