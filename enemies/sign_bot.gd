extends Enemy

const WALK_SPEED: float = 100.0

@onready var anim: AnimationPlayer = $AnimationPlayer

var walk_dir: Vector2 = Vector2.ZERO
var walk_rot: float = 0.0

func _on_gun_pickup(body: Node2D):
	state = EnemyState.ENTERING

func _ready():
	super._ready()
	anim.current_animation = "idle"

func _on_jumpsdds():
	anim.current_animation = "jump"

func _on_die():
	anim.current_animation = "hurt"
