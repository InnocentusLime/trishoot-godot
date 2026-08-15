extends Label

func _on_player_combo_level_changed(new_val: int):
	text = "x%d" % new_val
