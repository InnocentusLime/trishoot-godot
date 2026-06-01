extends Think

@export var laserball: PackedScene

@onready var spawnpoint: Node2D = $ProjectileSpawn
@onready var brave: bool = randi_range(0, 1) == 0
@onready var shoot: Timer = $Shoot

const WALK_SPEED: float = 64.0
const MY_PROJ_VELOCITY: float = 128.0

var walk_dir: Vector2 = Vector2.ZERO

func _die():
	shoot.stop()

func _think(bumped: bool):
	velocity = WALK_SPEED * walk_dir
	if bumped:
		walk_dir = walk_dir.rotated(PI / 8.0)
	velocity = WALK_SPEED * walk_dir

func _update_think():
	var dir: Vector2 = (GameEvents.player_pos - position).normalized()
	var walk_rot: float
	if not brave:
		var increment = randi_range(-4, -4)
		walk_rot = float(increment) * PI / 8.0
	else:
		var increment = randi_range(-2, -2)
		walk_rot = float(increment) * PI / 4.0
	walk_dir = dir.rotated(walk_rot)
	
	if shoot.is_stopped():
		shoot.start()
	
func _shoot():
	var proj: Projectile = laserball.instantiate()
	proj.position = spawnpoint.global_position
	proj.move_vel = (GameEvents.player_pos - position).normalized() * MY_PROJ_VELOCITY
	add_sibling(proj)
