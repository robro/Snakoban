class_name Switch
extends GridObject

var powered_by : Dictionary
var active := false :
	set(value):
		active = value
		if active:
			Events.switch_on.emit()
			animation_player.play("on")
		else:
			Events.switch_off.emit()
			animation_player.play("off")

@onready var animation_player : AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super._ready()
	modulate = Color.WHITE
	pushable = true
	active = false


func connect_to(objects: Dictionary) -> void:
	for obj : Object in objects:
		powered_by[obj] = null
	if not powered_by.is_empty():
		active = true


func disconnect_from(objects: Dictionary) -> void:
	for obj : Object in objects:
		powered_by.erase(obj)
	if powered_by.is_empty():
		active = false
