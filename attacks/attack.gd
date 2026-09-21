class_name Attack extends Area2D

@export var enabled: bool = true

func _on_attack(hurtbox: Area2D):
	if not enabled: return
	var to_dmg = hurtbox.get_parent()
	if to_dmg == null: return
	if to_dmg.has_method("_on_dmg"):
		to_dmg.call("_on_dmg", position)
