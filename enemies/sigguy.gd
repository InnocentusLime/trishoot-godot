extends Enemy

const TICKS_TO_SHOOT: int = 2

@export var player_see_range: float
@export var player_distance_min: float
@export var min_wall_dist: float
@export var laserball: PackedScene

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var spawnpoint: Node2D = $ProjectileSpawn

const WALK_SPEED: float = 30.0
var wander: bool = false
var walk_dir: Vector2 = Vector2.ZERO
var tick_to_shoot: int = TICKS_TO_SHOOT

func _on_entering():
	super._on_entering()
	anim.current_animation = "idle"

func _on_hopping_over():
	super._on_hopping_over()
	anim.current_animation = "jump"

func _on_knockback():
	super._on_knockback()
	anim.current_animation = "hurt"
	
func _on_alive():
	super._on_alive()

func _think():
	velocity = WALK_SPEED * walk_dir
	#if bumped_this_frame:
		#walk_dir = walk_dir.rotated(PI / 8.0)
	#velocity = WALK_SPEED * walk_dir

func _update_think():
	super._update_think()
	
	if tick_to_shoot == 0:
		_shoot()
		tick_to_shoot = TICKS_TO_SHOOT
		return
	
	var dir_to_player := GameEvents.player_pos - global_position
	if not wander:
		walk_dir = dir_to_player.normalized()
	else:
		var increment = randi_range(0, 8)
		var walk_rot := float(increment) * (2*PI / 8.0)
		walk_dir = Vector2.from_angle(walk_rot)
	wander = not wander
	tick_to_shoot -= 1
		
	#var dir: Vector2 = (GameEvents.player_pos - position).normalized()
	#var walk_rot: float
	#if not brave:
		#var increment = randi_range(-4, -4)
		#walk_rot = float(increment) * PI / 8.0
	#else:
		#var increment = randi_range(-2, -2)
		#walk_rot = float(increment) * PI / 4.0
		#walk_dir = dir.rotated(walk_rot)
	
func _shoot():
	var proj: Rocket = laserball.instantiate()
	proj.position = spawnpoint.global_position
	proj.move_dir = (GameEvents.player_pos - position).normalized()
	add_sibling(proj)
