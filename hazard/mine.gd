extends Area2D

@export var explosion: PackedScene

func _on_overlap(victim: Node2D):
	if not victim is Player: return
	var the_explosion: Node2D = explosion.instantiate()
	the_explosion.position = position
	add_sibling(the_explosion)
	if victim is Player:
		# NOTE: we call _on_dmg directly, because we are detecting
		#       the object itself, no the hurtbox
		victim._on_dmg(position, true, true)
	queue_free()
