class_name Beam
extends Node2D

@export var probe : RayCast2D
@export var beam_texture : TextureRect
@export var beam_area : Area2D
@export var beam_collision : CollisionShape2D


func _ready() -> void:
	set_beam_length()


func _process(_delta: float) -> void:
	set_beam_length()


func set_beam_length() -> void:
	var beam_length := 0
	var collider := probe.get_collider()

	if collider:
		beam_length = int((probe.global_position - probe.get_collision_point()).length() / 8) * 8
	else:
		beam_length = int(probe.target_position.x)

	beam_texture.size.x = beam_length
	beam_collision.shape.b.x = beam_length


func get_collider() -> Object:
	return probe.get_collider()
