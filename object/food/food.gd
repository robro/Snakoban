class_name Food
extends GridObject

var connected_to : Dictionary
var edible := true :
	set(value):
		edible = value
		if edible:
			animation_player.play("edible")
		else:
			animation_player.play("inedible")

@onready var animation_player : AnimationPlayer = $AnimationPlayer

signal eaten


func _ready() -> void:
	super._ready()
	edible = true


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
