extends Node2D

@export var laserball: PackedScene

const WALK_SPEED: float = 64.0
const SHOOT_COOLDOWN: float = 1.5
const MY_PROJ_VELOCITY: float = 128.0

var next_shot: float = SHOOT_COOLDOWN
var walk_dir: Vector2 = Vector2.ZERO

func _think(bumped: bool, delta: float, body: CharacterBody2D, player: AnimationPlayer):
	var dir = (GameEvents.player_pos - body.position).normalized()
	next_shot -= delta
	body.velocity = WALK_SPEED * walk_dir
	
	if next_shot <= 0.0: 
		var increment = randi_range(-4, -4)
		var walk_rot = float(increment) * PI / 8.0
		walk_dir = dir.rotated(walk_rot)
	if bumped:
		walk_dir = walk_dir.rotated(PI / 8.0)
	if next_shot <= 0.0:
		next_shot = SHOOT_COOLDOWN
		var proj: Projectile = laserball.instantiate()
		proj.position = global_position
		proj.move_vel = dir * MY_PROJ_VELOCITY
		body.add_sibling(proj)
