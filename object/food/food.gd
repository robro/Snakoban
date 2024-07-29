class_name Food
extends GridObject

@export var inedible_color := Color.PURPLE
var edible := true:
	set(value):
		edible = value
		modulate = color if edible else inedible_color

signal eaten


func eat() -> void:
	eaten.emit()
	queue_free()
