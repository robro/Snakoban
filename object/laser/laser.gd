class_name Laser
extends Node

var point: Vector2i
var active: bool
var atlas_x: int
var atlas_coord: Vector2i:
    get:
        return Vector2i(atlas_x, 0 if active else 1)
var direction: Vector2i:
    get:
        return Vector2i(Vector2.from_angle(atlas_x * (PI / 2)))


func _init(_point: Vector2i, _atlas_coord: Vector2i) -> void:
    point = _point
    atlas_x = _atlas_coord.x
    active = true if _atlas_coord.y == 0 else false
