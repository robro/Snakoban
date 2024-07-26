class_name Mover
extends Area2D

@export var color := Color.SANDY_BROWN


func _ready() -> void:
	Events.move.connect(_on_events_move)
	modulate = color


func _on_events_move() -> void:
	await get_tree().physics_frame
	move(Vector2.from_angle(rotation) * 8)


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
