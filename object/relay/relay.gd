class_name Relay
extends Area2D

@export var idle_color := Color.DIM_GRAY
@export var powered_color := Color.PURPLE
@export var beam : Beam


func _ready() -> void:
	modulate = idle_color
	beam_off()


func _physics_process(_delta: float) -> void:
	beam_off()


func power() -> void:
	if beam.enabled:
		return

	beam_on()
	var collider := beam.get_collider()
	if collider is Relay:
		collider.power()


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


func beam_on() -> void:
	beam.enabled = true
	modulate = powered_color


func beam_off() -> void:
	beam.enabled = false
	modulate = idle_color
