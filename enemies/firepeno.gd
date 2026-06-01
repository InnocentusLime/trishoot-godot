extends Think

@export var laserball: PackedScene

@onready var spawnpoint: Node2D = $ProjectileSpawn
@onready var chaintimer: Timer = $ChainTimer

const WALK_SPEED: float = 42.0
const MY_PROJ_VELOCITY: float = 200.0

var walk_dir: Vector2 = Vector2.ZERO

func _die():
	chaintimer.stop()

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
	
	if chaintimer.is_stopped():
		chaintimer.start()
	else:
		chaintimer.stop()
		
func _shoot():
	var dir = (GameEvents.player_pos - position).normalized()
	var proj: Projectile = laserball.instantiate()
	proj.position = spawnpoint.global_position
	proj.move_vel = dir.rotated(randi_range(-2, 2) * PI / 8.0) * MY_PROJ_VELOCITY
	add_sibling(proj)
