class_name Beam
extends Node2D

@export var probe : RayCast2D
@export var beam_texture : TextureRect
@export var beam_collision : CollisionShape2D
var enabled := true


func _ready() -> void:
	set_beam_length()


func _physics_process(_delta: float) -> void:
	set_beam_length()


func set_beam_length() -> void:
	var beam_length := 0
	if enabled:
		probe.force_raycast_update()
		var collider := probe.get_collider()
		if collider:
			beam_length = int((probe.global_position - probe.get_collision_point()).length() / 8) * 8

	beam_texture.size.x = beam_length
	beam_collision.shape.b.x = beam_length


func get_collider() -> Object:
	probe.force_raycast_update()
	return probe.get_collider()
