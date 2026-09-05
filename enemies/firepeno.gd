extends Enemy

const WALK_SPEED: float = 72.0
const MY_PROJ_VELOCITY: float = 160.0

@export var explosion_size: int
@export var shrapnel: PackedScene
@export var min_player_dist: float = 180 + randi_range(0, 3)*20.0
@export var explosion_time: float = 2.0 + randi_range(0, 4) * 1.0
@export var rotate_sign: float = -1.0 if randi_range(0, 1) < 1 else 1.0

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var explode_timer: Timer = $ExplodeTimer

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

func _on_alive():
	super._on_alive()
	explode_timer.start(explosion_time)

func _think():
	var to_player := (GameEvents.player_pos - position)
	var dir_to_player := to_player.normalized()
	if to_player.length() > min_player_dist:
		walk_dir = dir_to_player
	else:
		var perdir := Vector2(-dir_to_player.y, dir_to_player.x) * rotate_sign
		walk_dir = perdir
	velocity = WALK_SPEED * walk_dir

func _update_think():
	super._update_think()
	var dir_to_player := (GameEvents.player_pos - position).normalized()
	var perdir := Vector2(-dir_to_player.y, dir_to_player.x)
	walk_dir = perdir

func _on_explode():
	var increment := (2*PI) / float(explosion_size)
	for i in range(explosion_size):
		var angle := i * increment
		var proj: Projectile = shrapnel.instantiate()
		proj.position = global_position
		proj.move_vel = Vector2.from_angle(angle) * MY_PROJ_VELOCITY
		add_sibling(proj)
	queue_free()
		
