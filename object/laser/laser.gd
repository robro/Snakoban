class_name Laser
extends Area2D

@onready var beam : Beam = $Beam
var color := Color.PURPLE


func _ready() -> void:
	modulate = color


func move(offset: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(
		position,
		position + offset,
		15,
	)
	query.collide_with_areas = true
	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if result:
		return false

	position += offset
	return true
