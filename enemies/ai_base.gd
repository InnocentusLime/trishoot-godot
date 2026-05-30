class_name AIBase
extends Node2D

const KNOCKBACK_SPEED: float = 999.0
const OFFSCREEN_DELTA: float = PI / 5

enum EnemyLayer {ACTIVE = 2, DYING = 3}
enum EnemyState {ALIVE = 0, KNOCKBACK=1, OFFSCREEN=2}

var state: EnemyState = EnemyState.ALIVE
var knockback_dir: Vector2 = Vector2.ZERO
var bumped_this_frame: bool = false

@onready var think_tick: Timer = $ThinkTick
@onready var delete_timer: Timer = $DeleteTimer
@onready var die_angle_sign: int = (randi() & 2) - 1
@onready var hitspark: PackedScene = preload("res://hits/hitenemy.tscn")

@export var think_time: float

var body: CharacterBody2D
var impl_think: Callable
var impl_update_think: Callable

func _ready():
	body = get_parent()
	impl_think = Callable(body, "_think")
	impl_update_think = Callable(body, "_update_think")
	think_tick.start(0.1)

func _on_dmg(attack_pos: Vector2):
	if state != EnemyState.ALIVE: return
	body.set_collision_layer_value(EnemyLayer.ACTIVE, false)
	body.set_collision_layer_value(EnemyLayer.DYING, true)
	body.set_collision_mask_value(EnemyLayer.ACTIVE, false)
	state = EnemyState.KNOCKBACK
	knockback_dir = (body.position - attack_pos).normalized()
	delete_timer.start()
	think_tick.stop()

func _physics_process(delta):
	bumped_this_frame = body.move_and_slide()

	match state:
		EnemyState.KNOCKBACK: 
			body.velocity = KNOCKBACK_SPEED * knockback_dir
			if bumped_this_frame:
				GameEvents.enemy_hit_bounds.emit()
				# Don't collide with the level
				body.set_collision_mask_value(1, false)
				state = EnemyState.OFFSCREEN
				var hit: Node2D = hitspark.instantiate()
				hit.position = body.position + knockback_dir * 16.0
				body.add_sibling(hit)
		EnemyState.OFFSCREEN: 
			var offscreen_dir_angle: float = OFFSCREEN_DELTA * float(die_angle_sign)
			body.velocity = 1.6 * KNOCKBACK_SPEED * knockback_dir.rotated(offscreen_dir_angle)
		EnemyState.ALIVE:
			impl_think.call(bumped_this_frame)

func _lifetime_out():
	body.queue_free()

func _update_think():
	if state != EnemyState.ALIVE: return
	var k = 1.0 + 0.5 * randi_range(0, 3)
	think_tick.start(think_time * k)
	impl_update_think.call()
