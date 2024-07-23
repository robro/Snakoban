class_name Laser
extends Area2D

@onready var probe : RayCast2D = $Beam/Probe
@onready var beam_texture : TextureRect = $Beam/BeamTexture
@onready var beam_collision : CollisionShape2D = $Beam/BeamArea/Collision
var emitter := true
var active := true
var on_color := Color.PURPLE
var off_color := Color.DIM_GRAY
var beam_length : int = 0
var powered_relay : Laser


func _ready() -> void:
	beam_collision.shape = SegmentShape2D.new()
	beam_collision.shape.b = Vector2.ZERO
	modulate = on_color if active else off_color

	if not emitter:
		active = false


func _process(_delta: float) -> void:
	if powered_relay is Laser:
		powered_relay.active = false

	if not active:
		powered_relay = null
		modulate = off_color
		beam_texture.visible = false
		beam_collision.disabled = true
		return

	modulate = on_color

	var collider := probe.get_collider()
	if collider != null:
		if collider is Laser and collider.emitter == false:
			powered_relay = collider
			collider.active = true

		beam_length = int((probe.global_position - probe.get_collision_point()).length() / 8) * 8
	else:
		beam_length = int(probe.target_position.x)

	if beam_length > 0:
		beam_texture.visible = true
		beam_collision.disabled = false
		beam_texture.size.x = beam_length
		beam_collision.shape.b.x = beam_length
	else:
		beam_texture.visible = false
		beam_collision.disabled = true


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
