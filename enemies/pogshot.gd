extends Enemy

@export var laserball: PackedScene
@export var down_time: float
@export var shoot_time: float

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var spawnpoint: Node2D = $ProjectileSpawn
@onready var chaintimer: Timer = $ChainTimer

const WALK_SPEED: float = 42.0
const MY_PROJ_VELOCITY: float = 250.0
const ROT_INCREMENT: float = PI/40

var walk_dir: Vector2 = Vector2.ZERO
var shooting: bool = false

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
	pass
	#velocity = WALK_SPEED * walk_dir
	#if bumped_this_frame:
		#walk_dir = walk_dir.rotated(PI / 8.0)
	#velocity = WALK_SPEED * walk_dir

func _shoot():
	var increment := randi_range(-3, 3)
	var angle := increment*ROT_INCREMENT
	var proj_dir := (GameEvents.player_pos - position).normalized()
	proj_dir = proj_dir.rotated(angle)
	
	var proj: Projectile = laserball.instantiate()
	proj.position = spawnpoint.global_position
	proj.move_vel = proj_dir * MY_PROJ_VELOCITY
	add_sibling(proj)

func _update_think():
	shooting = !shooting
	if shooting: think_time = shoot_time
	else: think_time = down_time
	super._update_think()
	if shooting: chaintimer.start()
	else: chaintimer.stop()
