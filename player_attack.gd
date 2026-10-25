class_name PlayerAttack extends Area2D

signal enemies_killed(count: int)

@onready var block_sound: AudioStreamPlayer2D = $BlockSound

func attack(level: int):
	var damaged := 0
	var blocked := 0
	var to_dmg_list: Array[Node2D] = get_overlapping_bodies()
	for to_dmg in to_dmg_list:
		if to_dmg is Enemy:
			if to_dmg._on_dmg(global_position, level):
				damaged += 1
			else:
				blocked += 1
	
	var to_dmg_list2: Array[Area2D] = get_overlapping_areas()
	for to_dmg in to_dmg_list2:
		var parent: Node2D = to_dmg.get_parent()
		if parent == null: continue
		if parent.has_method("_on_dmg"):
				if not parent.call("_on_dmg", global_position, level):
					blocked += 1
				
	if blocked > 0:
		block_sound.play()
	if damaged > 0:
		enemies_killed.emit(damaged)
