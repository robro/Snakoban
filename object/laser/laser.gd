class_name Laser
extends GridObject

@export var color := Color.PURPLE
var beam_collider : Variant
@onready var beam : Beam = $Beam


func _ready() -> void:
	super._ready()
	pushable = true
	modulate = color
	grid.updated.connect(_on_grid_updated)
	update_beam.call_deferred()


func update_beam() -> void:
	if beam_collider is Relay:
		beam_collider.disconnect_from([self] as Array[Laser])
	elif beam_collider is Food:
		beam_collider.edible = true
	beam_collider = null

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
	beam_collider = cell
	beam.beam_texture.size.x = beam_size * grid.cell_size


func _on_grid_updated() -> void:
	update_beam()
