class_name Food
extends Area2D

const color := Color.DEEP_PINK

signal eaten


func _ready() -> void:
	modulate = color


func eat() -> void:
	emit_signal("eaten")
	queue_free()
