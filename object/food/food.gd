class_name Food
extends Node

var point: Vector2i
var atlas_coord: Vector2i


func _init(_point: Vector2i, _atlas_coord: Vector2i) -> void:
    point = _point
    atlas_coord = _atlas_coord
