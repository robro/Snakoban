class_name Laser
extends GridObject

var powering : Relay
@onready var beam : Beam = %Beam


func _ready() -> void:
	super._ready()
	pushable = true
	grid.updated.connect(_on_grid_updated)
	update_beam.call_deferred()


func update_beam() -> void:
	if powering is Relay:
		powering.disconnect_from([self] as Array[Laser])
		powering = null

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
		curr_cell.connect_to([self] as Array[Laser])
		powering = curr_cell
	beam.beam_texture.size.x = beam_size * grid.cell_size


func _on_grid_updated() -> void:
	update_beam()
