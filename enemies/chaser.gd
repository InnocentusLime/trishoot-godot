extends Enemy

const WALK_SPEED: float = 100.0

@onready var anim: AnimationPlayer = $AnimationPlayer

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

func _think():
	var dir = (GameEvents.player_pos - position).normalized()
	if bumped_this_frame:
		walk_dir = walk_dir.rotated(PI / 8.0)
	walk_dir = dir.rotated(walk_rot)
	velocity = WALK_SPEED * walk_dir

func _update_think():
	super._update_think()
	var increment = randi_range(-3, 3)
	walk_rot = float(increment)*1.5 * PI / 8.0
