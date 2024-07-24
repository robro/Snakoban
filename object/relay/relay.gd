class_name Relay
extends Area2D

@onready var beam : Beam = $Beam

const color := Color.DIM_GRAY
var laser_count := 0


func _init() -> void:
	modulate = color


func _process(_delta: float) -> void:
	for area in get_overlapping_areas():
		if area.collision_layer == 16:
			if is_equal_approx(abs(angle_difference(global_rotation, area.global_rotation)), PI):
				beam_off()
			else:
				beam_on()
			modulate = Color.PURPLE
			return

	beam_off()
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


func beam_on() -> void:
	beam.process_mode = Node.PROCESS_MODE_INHERIT
	beam.visible = true


func beam_off() -> void:
	beam.process_mode = Node.PROCESS_MODE_DISABLED
	beam.visible = false
