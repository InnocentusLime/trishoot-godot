extends Node2D

const WALK_SPEED: float = 100.0
const THINK_COOLDOWN: float = 1.2

var next_thought: float = THINK_COOLDOWN
var walk_dir: Vector2 = Vector2.ZERO
var walk_rot: float = 0.0

func _think(bumped: bool, delta: float, body: CharacterBody2D, player: AnimationPlayer):
	var dir = (GameEvents.player_pos - body.position).normalized()
	next_thought -= delta
	
	if bumped:
		walk_dir = walk_dir.rotated(PI / 8.0)
	if next_thought <= 0.0: 
		var increment = randi_range(-3, 3)
		walk_rot = float(increment)*1.5 * PI / 8.0
		next_thought = THINK_COOLDOWN * (1.0 + 0.5 * randi_range(0, 3))
	walk_dir = dir.rotated(walk_rot)
	body.velocity = WALK_SPEED * walk_dir
