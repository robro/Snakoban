class_name Food
extends GridObject

@export var inedible_color := Color.PURPLE
var connected_to : Dictionary
var edible := true :
	set(value):
		edible = value
		modulate = color if edible else inedible_color

signal eaten


func connect_to(objects: Dictionary) -> void:
	for obj : Object in objects:
		connected_to[obj] = null
	if not connected_to.is_empty():
		edible = false


func disconnect_from(objects: Dictionary) -> void:
	for obj : Object in objects:
		connected_to.erase(obj)
	if connected_to.is_empty():
		edible = true


func eat() -> void:
	eaten.emit()
	queue_free()
