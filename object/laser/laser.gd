class_name Laser
extends GridObject

@export var powered_color : Color
@export var self_powered : bool
var beam_collider : Variant
var power_sources : Array[Laser]
@onready var beam : Beam = $Beam


func _ready() -> void:
	super._ready()
	pushable = true
	if self_powered:
		power_sources.append(self)
	update_beam()


func connect_to(_power_sources: Array[Laser]) -> void:
	if self_powered:
		return
	var source_count := power_sources.size()
	for power_source in _power_sources:
		if not power_source in power_sources:
			power_sources.append(power_source)
	if source_count > power_sources.size():
		update_beam()


func disconnect_from(_power_sources: Array[Laser]) -> void:
	if self_powered:
		return
	var source_count := power_sources.size()
	for power_source in _power_sources:
		var source_idx := power_sources.find(power_source)
		if source_idx >= 0:
			power_sources.remove_at(source_idx)
	if source_count < power_sources.size():
		if beam_collider is Laser:
			beam_collider.disconnect_from(_power_sources)
		update_beam()


func update_beam() -> void:
	if beam_collider is Laser:
		beam_collider.disconnect_from(power_sources)
	elif beam_collider is Food:
		beam_collider.edible = true
	beam_collider = null
	if power_sources.is_empty():
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
	if cell is Food:
		cell.edible = false
	elif cell is BodyPart:
		cell.hurt.emit()
	elif cell is Laser:
		cell.connect_to(power_sources)
	beam_collider = cell
	beam.beam_texture.size.x = beam_size * grid.cell_size
	modulate = powered_color


func _on_grid_updated() -> void:
	if self_powered:
		update_beam()
