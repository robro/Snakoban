class_name Switch
extends GridObject

@export var powering : Array[Door]
var powered_by : Dictionary
var active := false :
	set(value):
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


func connect_to(objects: Dictionary) -> void:
	for obj : Object in objects:
		powered_by[obj] = null
	if not active and not powered_by.is_empty():
		active = true


func disconnect_from(objects: Dictionary) -> void:
	for obj : Object in objects:
		powered_by.erase(obj)
	if active and powered_by.is_empty():
		active = false
