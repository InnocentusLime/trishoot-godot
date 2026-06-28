class_name Projectile extends Area2D

const PARRIED_SPEED: float = 250.0

@export var move_vel: Vector2 = Vector2(-15.0, 0.0)

func _on_dmg(dmg_pos: Vector2):
	var move_abs: float = move_vel.length()
	var move_dir = (position - GameEvents.player_pos).normalized()
	move_vel = move_dir * PARRIED_SPEED

func _ready():
	GameEvents.game_over.connect(queue_free)

func _on_attack(hurtbox: Node2D):
	queue_free()
	var to_dmg = hurtbox.get_parent()
	if to_dmg == null: return
	if to_dmg.has_method("_on_dmg"):
		to_dmg.call("_on_dmg", position)

func _physics_process(delta: float):
	position += delta * move_vel
