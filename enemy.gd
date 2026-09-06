class_name Enemy extends CharacterBody2D

signal killed

enum EnemyLayer {ACTIVE = 2, DYING = 3}
enum EnemyState {ENTERING=-2, HOPPINGOVER=-1, ALIVE = 0, KNOCKBACK=1, OFFSCREEN=2}

const KNOCKBACK_SPEED: float = 999.0
const OFFSCREEN_DELTA: float = PI / 5
const ENTER_SPEED: float = 260.0
const JUMP_VELOCITY: Vector2 = Vector2(200, -300)
const JUMP_GRAVITY: float = 1000.0

@export var jump_when_entering: bool = true
@export var protection_level: int
@export var think_time: float
@export var state: EnemyState = EnemyState.ENTERING

@onready var hop: AudioStreamPlayer2D = $Hop
@onready var think_tick: Timer = $ThinkTick
@onready var delete_timer: Timer = $DeleteTimer
@onready var jump_timer: Timer = $JumpTimer
@onready var die_angle_sign: int = (randi() & 2) - 1
@onready var hitspark: PackedScene = preload("res://hits/hitenemy.tscn")


var jumps_on_left: bool = true
var die_quiet: bool
var knockback_dir: Vector2 = Vector2.ZERO
var bumped_this_frame: bool = false

func _think(): pass

func _ready():
	think_tick.connect("timeout", _update_think)
	delete_timer.connect("timeout", queue_free)
	jump_timer.connect("timeout", _jump_done)
	GameEvents.game_over.connect(_on_game_over)
	
	set_state(state, true)
	
func _physics_process(delta):
	bumped_this_frame = move_and_slide()
	match state:
		EnemyState.ALIVE: _think()
		EnemyState.HOPPINGOVER: velocity.y += JUMP_GRAVITY * delta
		EnemyState.KNOCKBACK when bumped_this_frame: set_state(EnemyState.OFFSCREEN)
	
func _on_game_over():
	die_quiet = true
	_on_dmg(Vector2(480, 282.2), true)

func _on_dmg(attack_pos: Vector2, level: int, force: bool = false) -> bool:
	if level < protection_level: return false
	knockback_dir = (position - attack_pos).normalized()
	return set_state(EnemyState.KNOCKBACK, force)

func _on_jump_zone():
	if jump_when_entering:
		set_state(EnemyState.HOPPINGOVER)
	else:
		set_state(EnemyState.ALIVE)

func _jump_done(): set_state(EnemyState.ALIVE)
	
func _on_entering():
	var speed_x_sign: float = 1.0 if jumps_on_left else -1.0
	velocity = Vector2(ENTER_SPEED * speed_x_sign, 0.0)
	
	# Collision flags
	collision_mask = 0
	collision_layer = 0
	set_collision_layer_value(EnemyLayer.ACTIVE, true)
	
func _on_hopping_over():
	var speed_x_sign: float = 1.0 if jumps_on_left else -1.0
	velocity = JUMP_VELOCITY * Vector2(speed_x_sign, 1.0)
	jump_timer.start()
	hop.play()
	
	# Collision flags
	collision_mask = 0
	collision_layer = 0
	set_collision_layer_value(EnemyLayer.ACTIVE, true)
	
func _on_alive():
	velocity = Vector2.ZERO
	_update_think()
	
	# Collision flags
	collision_mask = 0
	collision_layer = 0
	set_collision_layer_value(EnemyLayer.ACTIVE, true)
	set_collision_mask_value(1, true)

func _on_knockback():
	velocity = KNOCKBACK_SPEED * knockback_dir
	delete_timer.start()
	think_tick.stop()
	jump_timer.stop()
	killed.emit()
	
	# Collision flags
	collision_mask = 0
	collision_layer = 0
	set_collision_layer_value(EnemyLayer.DYING, true)
	set_collision_mask_value(1, true)
	
func _on_offscreen():
	var offscreen_dir_angle: float = OFFSCREEN_DELTA * float(die_angle_sign)
	velocity = 1.6 * KNOCKBACK_SPEED * knockback_dir.rotated(offscreen_dir_angle)
	GameEvents.shake.emit(1.0, false)
	
	# Collision flags
	collision_mask = 0
	collision_layer = 0
	
	var hit: HitEnemy = hitspark.instantiate()
	hit.be_quiet = die_quiet
	hit.position = position + knockback_dir * 16.0
	add_sibling(hit)

func _update_think():
	if state != EnemyState.ALIVE: return
	var k = 1.0 + 0.5 * randi_range(0, 3)
	think_tick.start(think_time * k)

func set_state(new_state: EnemyState, force: bool = false) -> bool:
	if not transition_allowed(new_state, force): return false
	state = new_state
	match new_state:
		EnemyState.ENTERING: _on_entering()
		EnemyState.HOPPINGOVER: _on_hopping_over()
		EnemyState.ALIVE: _on_alive()
		EnemyState.KNOCKBACK: _on_knockback()
		EnemyState.OFFSCREEN: _on_offscreen()
	return true

func transition_allowed(new_state: EnemyState, force: bool) -> bool:
	if force: return true
	if state == new_state: return false
	match new_state:
		EnemyState.HOPPINGOVER: return state == EnemyState.ENTERING
		EnemyState.ALIVE: return ALIVE_ENTRANCES.has(state)
		EnemyState.KNOCKBACK: return KNOCKBACK_ENTRANCES.has(state)
		EnemyState.OFFSCREEN: return state == EnemyState.KNOCKBACK
		_: return false

const ALIVE_ENTRANCES: Array[EnemyState] = [EnemyState.HOPPINGOVER, EnemyState.ENTERING]
const KNOCKBACK_ENTRANCES: Array[EnemyState] = [EnemyState.HOPPINGOVER, EnemyState.ALIVE]
