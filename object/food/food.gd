class_name Food
extends GridObject

var connected_to : Array[Laser]
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


func connect_to(lasers: Array[Laser]) -> Array[Laser]:
	var new_connections : Array[Laser] = []
	for laser in lasers:
		if not laser in connected_to:
			connected_to.append(laser)
			new_connections.append(laser)
	edible = false
	return new_connections


func disconnect_from(lasers: Array[Laser]) -> Array[Laser]:
	var new_disconnections : Array[Laser] = []
	for laser in lasers:
		if laser in connected_to:
			connected_to.remove_at(connected_to.find(laser))
	if connected_to.is_empty():
		edible = true
	return new_disconnections


func eat() -> void:
	eaten.emit()
	queue_free()
