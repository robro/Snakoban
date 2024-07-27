class_name Beam
extends Node2D

var enabled := true
@onready var beam_texture : TextureRect = %"Beam Rect"


func _ready() -> void:
	set_beam_length()


func _physics_process(_delta: float) -> void:
	set_beam_length()


func set_beam_length() -> void:
	pass


func get_collider() -> Object:
	return null
