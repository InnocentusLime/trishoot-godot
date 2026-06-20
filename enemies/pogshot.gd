extends Enemy

@export var laserball: PackedScene

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var spawnpoint: Node2D = $ProjectileSpawn

const WALK_SPEED: float = 42.0
const MY_PROJ_VELOCITY: float = 100.0

var walk_dir: Vector2 = Vector2.ZERO

func _ready():
	super._ready()
	anim.current_animation = "idle"

func _on_jump():
	anim.current_animation = "jump"

func _on_die():
	anim.current_animation = "hurt"

func _on_think():
	velocity = WALK_SPEED * walk_dir
	if bumped_this_frame:
		walk_dir = walk_dir.rotated(PI / 8.0)
	velocity = WALK_SPEED * walk_dir

func _on_think_update():
	var dir = (GameEvents.player_pos - position).normalized()
	var increment = randi_range(-4, -4)
	var walk_rot = float(increment) * PI / 8.0
	walk_dir = dir.rotated(walk_rot)
	
	var proj_increment = PI / 4
	for i in range(-1, 2):
		var proj: Projectile = laserball.instantiate()
		proj.position = spawnpoint.global_position
		proj.move_vel = dir.rotated(i * proj_increment) * MY_PROJ_VELOCITY
		add_sibling(proj)
