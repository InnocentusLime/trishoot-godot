extends Think

@export var laserball: PackedScene

@onready var spawnpoint: Node2D = $ProjectileSpawn

const WALK_SPEED: float = 42.0
const MY_PROJ_VELOCITY: float = 256.0

var walk_dir: Vector2 = Vector2.ZERO

func _die(): pass

func _think(bumped: bool):
	velocity = WALK_SPEED * walk_dir
	if bumped:
		walk_dir = walk_dir.rotated(PI / 8.0)
	velocity = WALK_SPEED * walk_dir

func _update_think():
	var dir = (GameEvents.player_pos - position).normalized()
	var increment = randi_range(-4, -4)
	var walk_rot = float(increment) * PI / 8.0
	walk_dir = dir.rotated(walk_rot)
	
	var proj_increment = PI / 8
	for i in range(-3, 3):
		var proj: Projectile = laserball.instantiate()
		proj.position = spawnpoint.global_position
		proj.move_vel = dir.rotated(i * proj_increment) * MY_PROJ_VELOCITY
		add_sibling(proj)
