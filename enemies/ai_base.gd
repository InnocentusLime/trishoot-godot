class_name AIBase
extends Node2D

enum EnemyLayer {ACTIVE = 2, DYING = 3}
enum EnemyState {ENTERING=-2, HOPPINGOVER=-1, ALIVE = 0, KNOCKBACK=1, OFFSCREEN=2}

const KNOCKBACK_SPEED: float = 999.0
const OFFSCREEN_DELTA: float = PI / 5
const ENTER_SPEED: float = 260.0
const JUMP_VELOCITY: Vector2 = Vector2(200, -300)
const JUMP_GRAVITY: float = 1000.0
const LEFT_JUMP_X: float = 150.0
const RIGHT_JUMP_X: float = 800.0

var state: EnemyState = EnemyState.ENTERING
var knockback_dir: Vector2 = Vector2.ZERO
var bumped_this_frame: bool = false

@onready var hop: AudioStreamPlayer2D = $Hop
@onready var think_tick: Timer = $ThinkTick
@onready var delete_timer: Timer = $DeleteTimer
@onready var jump_timer: Timer = $JumpTimer
@onready var die_angle_sign: int = (randi() & 2) - 1
@onready var hitspark: PackedScene = preload("res://hits/hitenemy.tscn")

@export var think_time: float

var body: CharacterBody2D
var impl_think: Callable
var impl_update_think: Callable
var impl_die: Callable
var impl_jump: Callable

var jumps_on_left: bool = true

func _ready():
	body = get_parent()
	impl_think = Callable(body, "_think")
	impl_update_think = Callable(body, "_update_think")
	impl_die = Callable(body, "_die")
	impl_jump = Callable(body, "_jump")
	jumps_on_left = body.position.x < LEFT_JUMP_X
	if jumps_on_left: body.velocity = Vector2(ENTER_SPEED, 0.0)
	else: body.velocity = Vector2(-ENTER_SPEED, 0.0)
	GameEvents.game_over.connect(_on_game_over)
	
func _on_game_over(): _on_dmg(Vector2(480, 282.2), true)

func _on_dmg(attack_pos: Vector2, force: bool = false) -> bool:
	if state != EnemyState.ALIVE and not force: return false
	body.set_collision_layer_value(EnemyLayer.ACTIVE, false)
	body.set_collision_layer_value(EnemyLayer.DYING, true)
	body.set_collision_mask_value(EnemyLayer.ACTIVE, false)
	state = EnemyState.KNOCKBACK
	knockback_dir = (body.position - attack_pos).normalized()
	delete_timer.start()
	think_tick.stop()
	jump_timer.stop()
	impl_die.call()
	body.velocity = KNOCKBACK_SPEED * knockback_dir
	GameEvents.enemy_died.emit()
	return true

func _physics_process(delta):
	bumped_this_frame = body.move_and_slide()

	match state:
		EnemyState.ALIVE: impl_think.call(bumped_this_frame)
		EnemyState.HOPPINGOVER: body.velocity.y += JUMP_GRAVITY * delta
		EnemyState.KNOCKBACK when bumped_this_frame:
			state = EnemyState.OFFSCREEN
			GameEvents.shake.emit(1.0, false)
			# Don't collide with the level
			body.set_collision_mask_value(1, false)
			var hit: Node2D = hitspark.instantiate()
			hit.position = body.position + knockback_dir * 16.0
			body.add_sibling(hit)
			var offscreen_dir_angle: float = OFFSCREEN_DELTA * float(die_angle_sign)
			body.velocity = 1.6 * KNOCKBACK_SPEED * knockback_dir.rotated(offscreen_dir_angle)
		EnemyState.ENTERING:
			var jump_start = false
			if jumps_on_left and body.position.x >= LEFT_JUMP_X: 
				body.velocity = JUMP_VELOCITY
				jump_start = true
			elif not jumps_on_left and body.position.x <= RIGHT_JUMP_X: 
				body.velocity = JUMP_VELOCITY * Vector2(-1.0, 1.0)
				jump_start = true
			if jump_start:
				state = EnemyState.HOPPINGOVER
				jump_timer.start()
				impl_jump.call()
				hop.play()

func _jump_done():
	body.set_collision_mask_value(1, true)
	think_tick.start(randf_range(0.1, 0.4))
	state = EnemyState.ALIVE

func _lifetime_out():
	GameEvents.enemy_despawned.emit()
	body.queue_free()

func _update_think():
	if state != EnemyState.ALIVE: return
	var k = 1.0 + 0.5 * randi_range(0, 3)
	think_tick.start(think_time * k)
	impl_update_think.call()
	body.set_collision_mask_value(EnemyLayer.ACTIVE, randi_range(0, 2) == 2)
