class_name Box
extends Node

var point: Vector2i
var id: int
var atlas_coord: Vector2i


func _init(_point: Vector2i, _id: int, _atlas_coord: Vector2i) -> void:
    point = _point
    id = _id
    atlas_coord = _atlas_coord
