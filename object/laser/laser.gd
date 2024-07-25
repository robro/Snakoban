class_name Laser
extends Area2D

@export var beam : Beam
var color := Color.PURPLE


func _ready() -> void:
	modulate = color


func _process(_delta: float) -> void:
	var collider := beam.get_collider()
	if collider is Relay:
		collider.power_on()


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
