class_name Beam
extends Node2D

@export var probe : RayCast2D
@export var beam_texture : TextureRect
@export var beam_area : Area2D
@export var beam_collision : CollisionShape2D


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
