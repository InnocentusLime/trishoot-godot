extends Enemy

@export var laserball: PackedScene

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var spawnpoint: Node2D = $ProjectileSpawn
@onready var brave: bool = randi_range(0, 1) == 0
@onready var shoot: Timer = $Shoot

const WALK_SPEED: float = 64.0
const MY_PROJ_VELOCITY: float = 128.0

var walk_dir: Vector2 = Vector2.ZERO

func _ready():
	super._ready()
	anim.current_animation = "idle"

func _on_jump():
	anim.current_animation = "jump"

func _on_die():
	anim.current_animation = "hurt"
	shoot.stop()

func _on_think():
	velocity = WALK_SPEED * walk_dir
	if bumped_this_frame:
		walk_dir = walk_dir.rotated(PI / 8.0)
	velocity = WALK_SPEED * walk_dir

func _on_think_update():
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
