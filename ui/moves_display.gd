extends Label


func _ready() -> void:
	Events.move_count_updated.connect(_on_events_moveCountUpdated)


func _on_events_moveCountUpdated() -> void:
	text = "moves: %s" % Stats.moves
