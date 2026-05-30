class_name Projectile
extends Area2D

var move_vel: Vector2 = Vector2(-15.0, 0.0)

func _on_attack(hurtbox: Area2D):
	var to_dmg = hurtbox.get_parent()
	if to_dmg == null: return
	if to_dmg.has_method("_on_dmg"):
		to_dmg.call("_on_dmg", position)

func _physics_process(delta: float):
	position += delta * move_vel
