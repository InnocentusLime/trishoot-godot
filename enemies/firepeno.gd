extends Enemy

@export var laserball: PackedScene

@onready var spawnpoint: Node2D = $ProjectileSpawn
@onready var chaintimer: Timer = $ChainTimer
@onready var anim: AnimationPlayer = $AnimationPlayer

const WALK_SPEED: float = 42.0
const MY_PROJ_VELOCITY: float = 200.0

var walk_dir: Vector2 = Vector2.ZERO

func _on_entering():
	super._on_entering()
	anim.current_animation = "idle"

func _on_hopping_over():
	super._on_hopping_over()
	anim.current_animation = "jump"

func _on_knockback():
	super._on_knockback()
	anim.current_animation = "hurt"
	chaintimer.stop()

func _think():
	velocity = WALK_SPEED * walk_dir
	if bumped_this_frame:
		walk_dir = walk_dir.rotated(PI / 8.0)
	velocity = WALK_SPEED * walk_dir

func _update_think():
	super._update_think()
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
