class_name BodyPart
extends GridObject

var prev_part : BodyPart
var next_part : BodyPart
var prev_coord : Vector2
@onready var sprite : AnimatedSprite2D = %Sprite
@onready var animation_player : AnimationPlayer = %AnimationPlayer

signal hurt


func _ready() -> void:
	super._ready()
	prev_coord = grid_coord


func _on_grid_updated() -> void:
	update_animation()


func move(direction: Vector2i) -> bool:
	var cell : Variant = grid.get_cell(grid_coord + direction)
	if cell is GridObject and cell.pushable:
		cell.move(direction)
	var curr_coord := grid_coord
	if super.move(direction) == false:
		return false
	prev_coord = curr_coord
	if next_part and next_part.is_node_ready():
		next_part.move(Vector2(next_part.grid_coord).direction_to(prev_coord))
	return true


func update_animation() -> void:
	if next_part:
		rotation = next_part.position.angle_to_point(position)
	elif prev_part:
		rotation = position.angle_to_point(prev_part.position)
	else:
		rotation = 0

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
