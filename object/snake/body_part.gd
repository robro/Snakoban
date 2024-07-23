class_name BodyPart
extends Node2D

@onready var sprite : AnimatedSprite2D = $Sprite
@onready var collision : Area2D = $Collision
var prev_part : BodyPart
var next_part : BodyPart
var prev_pos : Vector2


func _process(_delta: float) -> void:
	if next_part:
		rotation = next_part.position.angle_to_point(position)
	elif prev_part:
		rotation = position.angle_to_point(prev_part.position)

	update_animation()


func update_position(_position: Vector2) -> void:
	prev_pos = position
	position = _position

	if next_part:
		next_part.update_position(prev_pos)


func update_animation() -> void:
	if not prev_part:
		sprite.animation = "head"

	elif not next_part:
		sprite.animation = "tail"

	elif rotation == prev_part.rotation:
		sprite.animation = "straight"

	else:
		sprite.animation = "bent"
		if angle_difference(rotation, prev_part.rotation) > 0:
			sprite.flip_v = true
		else:
			sprite.flip_v = false
