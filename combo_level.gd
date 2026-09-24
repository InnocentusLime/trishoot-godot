extends Label

func _on_player_weapon_lvl_changed(new_val: int):
	text = "P%d" % new_val
