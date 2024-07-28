class_name Relay
extends GridObject

@export var idle_color := Color.DIM_GRAY
@export var powered_color := Color.PURPLE
@export var beam : Beam
var beaming : Variant
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
	if beaming is Relay and disconnected:
		beaming.disconnect_from(_power_sources)
	elif beaming is Food:
		beaming.edible = true
	if power_sources.is_empty():
		power_off()


func update_beam() -> void:
	beaming = null
	if power_sources.is_empty():
		beam.beam_texture.size.x = 0
		return

	var beam_size := 0
	var direction := Vector2i(Vector2.from_angle(rotation))
	var cell : Variant
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
	beaming = cell
	beam.beam_texture.size.x = beam_size * grid.cell_size
