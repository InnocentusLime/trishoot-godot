extends Enemy

@export var laserball: PackedScene

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var spawnpoint: Node2D = $ProjectileSpawn

const WALK_SPEED: float = 42.0
const MY_PROJ_VELOCITY: float = 100.0

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
	
	var proj_increment = PI / 4
	for i in range(-1, 2):
		var proj: Projectile = laserball.instantiate()
		proj.position = spawnpoint.global_position
		proj.move_vel = dir.rotated(i * proj_increment) * MY_PROJ_VELOCITY
		add_sibling(proj)
