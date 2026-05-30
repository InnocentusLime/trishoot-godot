extends Area2D

func _on_attack(hurtbox: Area2D):
	var to_dmg = hurtbox.get_parent()
	if to_dmg == null: return
	if to_dmg.has_method("_on_dmg"):
		to_dmg.call("_on_dmg", position)
