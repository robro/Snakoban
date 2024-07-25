class_name Food
extends Area2D

const edible_color := Color.DEEP_PINK
const inedible_color := Color.PURPLE
var edible := true:
	set(v):
		edible = v
		modulate = edible_color if edible else inedible_color

signal eaten


func _ready() -> void:
	edible = true


func _physics_process(_delta: float) -> void:
	edible = true


func eat() -> void:
	emit_signal("eaten")
	queue_free()
