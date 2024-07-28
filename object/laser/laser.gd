class_name Laser
extends GridObject

var beaming : Variant
@onready var beam : Beam = %Beam


func _ready() -> void:
	super._ready()
	pushable = true
	grid.updated.connect(_on_grid_updated)
	update_beam.call_deferred()


func update_beam() -> void:
	if beaming is Relay:
		beaming.disconnect_from([self] as Array[Laser])
	elif beaming is Food:
		beaming.edible = true
	beaming = null

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
		cell.connect_to([self] as Array[Laser])
	beaming = cell
	beam.beam_texture.size.x = beam_size * grid.cell_size


func _on_grid_updated() -> void:
	update_beam()
