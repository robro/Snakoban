class_name Laser
extends GridObject

@onready var beam : Beam = %Beam


func _ready() -> void:
	super._ready()
	pushable = true
	grid.updated.connect(_on_grid_updated)


func _on_grid_updated() -> void:
	# resize beam
	pass
