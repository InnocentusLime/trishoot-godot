class_name Rocket
extends Area2D

const PARRIED_SPEED: float = 400.0

@export var rot_weight: float
@export var move_vel: float
@export var move_dir: Vector2
@export var explosion: PackedScene
@export var level_to_parry: int

var parried: bool = false

func _on_dmg(dmg_pos: Vector2, level: int) -> bool:
	if level < level_to_parry: return false
	move_dir = (position - GameEvents.player_pos).normalized()
	move_vel = PARRIED_SPEED
	parried = true
	return true

func _physics_process(delta):
	var player_dir := (GameEvents.player_pos - position).normalized()
	if not parried:
		move_dir = move_dir.lerp(player_dir, rot_weight*delta)
	position += move_dir*move_vel*delta
	rotation = move_dir.angle()
	
	for node in get_overlapping_bodies():
		if node is Enemy and parried:
			node._on_dmg(position, 999)
			explode()

func _on_collision(player_hurtbox: Area2D):
	var parent := player_hurtbox.get_parent()
	if parent == null: return
	if parent is Player:
		parent._on_dmg(position, true)
		explode()
		
func explode():
	var the_explosion: Node2D = explosion.instantiate()
	the_explosion.position = position
	add_sibling(the_explosion)
	queue_free()
