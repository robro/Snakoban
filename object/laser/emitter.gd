class_name Emitter
extends Node

var point: Vector2i
var id: int
var atlas_x: int
var atlas_coord: Vector2i:
    get:
        return Vector2i(atlas_x, 0)
var direction: Vector2i:
    get:
        return Vector2i(Vector2.from_angle(atlas_x * (PI / 2)))


func _init(_point: Vector2i, _id: int, _atlas_x: int) -> void:
    point = _point
    id = _id
    atlas_x = _atlas_x
