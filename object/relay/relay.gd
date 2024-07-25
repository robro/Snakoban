class_name Relay
extends Area2D

@export var beam : Beam
const off_color := Color.DIM_GRAY
const on_color := Color.PURPLE


func _ready() -> void:
	modulate = off_color
	beam_off()


func _physics_process(_delta: float) -> void:
	modulate = off_color
	beam_off()


func power_on() -> void:
	if beam.visible:
		return
	beam_on()
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


func beam_on() -> void:
	beam.visible = true
	modulate = on_color


func beam_off() -> void:
	beam.visible = false
	modulate = off_color
