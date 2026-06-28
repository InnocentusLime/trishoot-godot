extends Enemy

const WALK_SPEED: float = 100.0

@onready var anim: AnimationPlayer = $AnimationPlayer

var walk_dir: Vector2 = Vector2.ZERO
var walk_rot: float = 0.0

func _on_gun_pickup(body: Node2D):
	set_state(EnemyState.ENTERING, true)

func _on_entering():
	super._on_entering()
	anim.current_animation = "idle"

func _on_hopping_over():
	super._on_hopping_over()
	anim.current_animation = "jump"

func _on_knockback():
	super._on_knockback()
	anim.current_animation = "hurt"
