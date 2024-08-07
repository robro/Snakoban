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
	if lasers.is_empty():
		return []
	var connected : Array[Laser] = []
	for laser in lasers:
		if not laser in connected_to:
			connected_to.append(laser)
			connected.append(laser)
	if connected:
		edible = false
	return connected


func disconnect_from(lasers: Array[Laser]) -> void:
	if lasers.is_empty():
		return
	for laser in lasers:
		connected_to.erase(laser)
	if connected_to.is_empty():
		edible = true


func eat() -> void:
	eaten.emit()
	queue_free()
