extends Enemy

const WALK_SPEED: float = 100.0

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var attack: Attack = $Attack

var walk_dir: Vector2 = Vector2.ZERO
var walk_rot: float = 0.0

func _on_entering():
	super._on_entering()
	anim.current_animation = "idle"

func _on_hopping_over():
	super._on_hopping_over()
	anim.current_animation = "jump"

func _on_knockback():
	super._on_knockback()
	anim.current_animation = "hurt"
	# Shut up attack! I am busy dying!
	attack.process_mode = Node.PROCESS_MODE_DISABLED

func _think():
	if bumped_this_frame: new_walk_direction()
	velocity = WALK_SPEED * walk_dir

func _update_think():
	super._update_think()
	new_walk_direction()
	
func new_walk_direction():
	var dir := (GameEvents.player_pos - position).normalized()
	var angle := dir.angle()
	# Quantesize the angle
	angle = floor(angle/PI*5)/5*PI
	walk_dir = Vector2.from_angle(angle)
