class_name Beam
extends Node2D

@onready var probe : RayCast2D = $Probe
@onready var beam_texture : TextureRect = $BeamTexture
@onready var beam_collision : CollisionShape2D = $BeamArea/Collision


func _process(_delta: float) -> void:
	var beam_length := get_beam_length()
	beam_texture.size.x = beam_length
	beam_collision.shape.b.x = beam_length


func get_beam_length() -> int:
	var collider := probe.get_collider()
	if collider != null:
		return int((probe.global_position - probe.get_collision_point()).length() / 8) * 8
	else:
		return int(probe.target_position.x)
