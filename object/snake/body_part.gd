class_name BodyPart
extends Node2D

@export var sprite : AnimatedSprite2D
@export var collision : Area2D
var prev_part : BodyPart
var next_part : BodyPart
var prev_pos : Vector2

signal hurt


func _ready() -> void:
	collision.area_entered.connect(_on_area_entered)
	update_animation()


func _on_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(5):
		emit_signal("hurt")


func update_position(new_position: Vector2) -> void:
	prev_pos = position
	position = new_position

	if next_part:
		next_part.update_position(prev_pos)


func update_animation() -> void:
	if next_part:
		rotation = next_part.position.angle_to_point(position)

	elif prev_part:
		rotation = position.angle_to_point(prev_part.position)

	sprite.rotation = 0

	if not prev_part:
		sprite.animation = "head"

	elif not next_part:
		sprite.animation = "tail"

	elif rotation == prev_part.rotation:
		sprite.animation = "straight"

	else:
		sprite.animation = "bent"
		if angle_difference(rotation, prev_part.rotation) > 0:
			sprite.rotation = -PI / 2

	if next_part:
		next_part.update_animation()
