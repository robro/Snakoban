class_name Box
extends GridObject

@export var color := Color.SANDY_BROWN


func _ready() -> void:
	super._ready()
	pushable = true
	modulate = color
