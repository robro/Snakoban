extends Label


func _ready() -> void:
	Events.push_count_updated.connect(_on_events_pushCountUpdated)


func _on_events_pushCountUpdated() -> void:
	text = "pushes: %s" % Stats.pushes
