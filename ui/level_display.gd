extends Label

func _ready() -> void:
	Events.level_num_updated.connect(_on_events_levelNumUpdated)

func _on_events_levelNumUpdated() -> void:
	text = "%02d" % Stats.level_num
