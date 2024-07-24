class_name Laser
extends Area2D

@onready var probe : RayCast2D = $Beam/Probe
@onready var beam_texture : TextureRect = $Beam/BeamTexture
@onready var beam_collision : CollisionShape2D = $Beam/BeamArea/Collision
var emitter := true
var color_on := Color.PURPLE
var color_off := Color.DIM_GRAY
var beam_length : int = 0
var powering : Laser = null
var powered_by : Array[Laser] = []


func _ready() -> void:
	beam_collision.shape = SegmentShape2D.new()
	beam_collision.shape.b = Vector2.ZERO


func _process(_delta: float) -> void:
	update_beam()


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


func update_beam() -> void:
	if not emitter and powered_by.is_empty():
		if powering is Laser:
			disconnect_from_relay(powering)
		modulate = color_off
		beam_texture.size.x = 0
		beam_collision.shape.b.x = 0
		return

	var collider := probe.get_collider()

	if collider != null:
		if collider is Laser:
			if collider.emitter == false:
				if powering is Laser and powering != collider:
					disconnect_from_relay(powering)

				collider.connect_to_power(self)
				powering = collider
		else:
			if powering is Laser:
				disconnect_from_relay(powering)

		beam_length = int((probe.global_position - probe.get_collision_point()).length() / 8) * 8

	else:
		if powering is Laser:
			disconnect_from_relay(powering)

		beam_length = int(probe.target_position.x)

	beam_texture.size.x = beam_length
	beam_collision.shape.b.x = beam_length
	modulate = color_on


func connect_to_power(laser: Laser) -> void:
	if laser in powered_by:
		return
	# print("getting power from ", laser)
	powered_by.append(laser)


func disconnect_from_relay(relay: Laser) -> void:
	# print("disconnecting from ", relay)
	var self_idx := relay.powered_by.find(self)
	if self_idx >= 0:
		relay.powered_by.remove_at(self_idx)

	powering = null
