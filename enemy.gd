extends CharacterBody2D

const KNOCKBACK_SPEED: float = 999.0
const OFFSCREEN_DELTA: float = PI / 5

enum EnemyLayer {ACTIVE = 2, DYING = 3}
enum EnemyState {ALIVE = 0, KNOCKBACK=1, OFFSCREEN=2}

var lifetime: float = 1.0
var state: EnemyState = EnemyState.ALIVE
var knockback_dir: Vector2 = Vector2.ZERO

@onready var die_angle_sign: int = (randi() & 2) - 1
@onready var hit_player: AudioStreamPlayer2D = $HitPlayer

func _on_dmg(attack_pos: Vector2):
	if state != EnemyState.ALIVE: return
	prints("ouch!", self)
	set_collision_layer_value(EnemyLayer.ACTIVE, false)
	set_collision_layer_value(EnemyLayer.DYING, true)
	set_collision_mask_value(EnemyLayer.ACTIVE, false)
	state = EnemyState.KNOCKBACK
	knockback_dir = (position - attack_pos).normalized()
	
func _physics_process(delta):
	match state:
		EnemyState.KNOCKBACK: 
			velocity = KNOCKBACK_SPEED * knockback_dir
		EnemyState.OFFSCREEN: 
			var offscreen_dir_angle: float = OFFSCREEN_DELTA * float(die_angle_sign)
			velocity = 1.6 * KNOCKBACK_SPEED * knockback_dir.rotated(offscreen_dir_angle)
		_: pass
	if move_and_slide() and state == EnemyState.KNOCKBACK:
		# Don't collide with the level
		set_collision_mask_value(1, false)
		state = EnemyState.OFFSCREEN
		hit_player.play()
		get_parent().call("_on_enemy_hit_bounds")
		
func _process(delta):
	if state == EnemyState.OFFSCREEN:
		lifetime -= delta
	if lifetime <= 0.0:
		prints("delete", self)
		queue_free()
		
