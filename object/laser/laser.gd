class_name Laser
extends Area2D

@export var color := Color.PURPLE
@export var beam : Beam


func _ready() -> void:
	modulate = color


func _physics_process(_delta: float) -> void:
	var collider := beam.get_collider()
	if collider is Relay:
		collider.power(self)


func move(offset: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(
		position,
		position + offset,
		0b1111,
	)
	query.collide_with_areas = true
	var result := get_world_2d().direct_space_state.intersect_ray(query)
	if result:
		return false

	position += offset
	return true
