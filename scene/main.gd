extends Node2D


func _process(_delta: float) -> void:
	get_tree().change_scene_to_file(Levels.level_paths[Levels.curr_level_idx])
