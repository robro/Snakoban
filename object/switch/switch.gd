class_name Switch
extends GridObject

@export var powering : Array[Door]
var powered_by : Array[Laser]
var active := false :
	set(value):
		if active == value:
			return
		active = value
		if active:
			for door in powering:
				door.open()
			animation_player.play("on")
		else:
			for door in powering:
				door.close()
			animation_player.play("off")

@onready var animation_player : AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super._ready()
	pushable = true


func connect_to(lasers: Array[Laser]) -> Array[Laser]:
	if lasers.is_empty():
		return []
	var connections : Array[Laser] = []
	for laser in lasers:
		if not laser in powered_by:
			powered_by.append(laser)
			connections.append(laser)
	if not active and powered_by.size() > 0:
		active = true
	return connections


func disconnect_from(lasers: Array[Laser]) -> void:
	if lasers.is_empty():
		return
	for laser in lasers:
		powered_by.erase(laser)
	if active and powered_by.is_empty():
		active = false
