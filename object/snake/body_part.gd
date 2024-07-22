class_name BodyPart
extends StaticBody2D

@onready var sprite : AnimatedSprite2D = $Sprite
var prev_part : BodyPart
var next_part : BodyPart
var facing : Vector2


func _process(_delta: float) -> void:
	if not prev_part:
		sprite.animation = "head"
		sprite.frame = roundi(pos_angle(facing.angle()) / (PI / 2))

	elif not next_part:
		sprite.animation = "tail"
		sprite.frame = roundi(pos_angle(prev_part.facing.angle()) / (PI / 2))

	elif facing == prev_part.facing:
		sprite.animation = "straight"
		sprite.frame = roundi(pos_angle(facing.angle()) / (PI / 2))

	else:
		sprite.animation = "bent"
		sprite.frame = roundi(pos_angle(facing.angle() + angle_difference(prev_part.facing.angle(), facing.angle()) / PI - 0.5) / (PI / 2))


func pos_angle(angle: float) -> float:
	return fposmod(angle, TAU)


func update_position(_facing: Vector2, _position: Vector2) -> void:
	if next_part:
		next_part.update_position(facing, position)
	facing = _facing
	position = _position
