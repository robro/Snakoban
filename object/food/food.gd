class_name Food
extends GridObject

@export var edible_color := Color.DEEP_PINK
@export var inedible_color := Color.PURPLE
var edible := true:
	set(v):
		edible = v
		modulate = edible_color if edible else inedible_color

signal eaten


func _ready() -> void:
	super._ready()
	edible = true


func eat() -> void:
	eaten.emit()
	queue_free()
