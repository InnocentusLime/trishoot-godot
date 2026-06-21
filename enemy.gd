class_name Enemy
extends CharacterBody2D

enum EnemyLayer {ACTIVE = 2, DYING = 3}
enum EnemyState {ENTERING=-2, HOPPINGOVER=-1, ALIVE = 0, KNOCKBACK=1, OFFSCREEN=2}

const KNOCKBACK_SPEED: float = 999.0
const OFFSCREEN_DELTA: float = PI / 5
const ENTER_SPEED: float = 260.0
const JUMP_VELOCITY: Vector2 = Vector2(200, -300)
const JUMP_GRAVITY: float = 1000.0

var knockback_dir: Vector2 = Vector2.ZERO
var bumped_this_frame: bool = false

@onready var hop: AudioStreamPlayer2D = $Hop
@onready var think_tick: Timer = $ThinkTick
@onready var delete_timer: Timer = $DeleteTimer
@onready var jump_timer: Timer = $JumpTimer
@onready var die_angle_sign: int = (randi() & 2) - 1
@onready var hitspark: PackedScene = preload("res://hits/hitenemy.tscn")

@export var think_time: float
@export var state: EnemyState = EnemyState.ENTERING
@export var jumps_on_left: bool = true
@export var die_quiet: bool

func _on_die(): pass
func _on_think(): pass
func _on_think_update(): pass
func _on_jump(): pass
func _on_think_ready(): pass

func _ready():
	think_tick.connect("timeout", _update_think)
	delete_timer.connect("timeout", _lifetime_out)
	jump_timer.connect("timeout", _jump_done)
	
	GameEvents.game_over.connect(_on_game_over)
	
func _on_game_over():
	die_quiet = true
	_on_dmg(Vector2(480, 282.2), true)

func _on_dmg(attack_pos: Vector2, force: bool = false) -> bool:
	if state != EnemyState.ALIVE and not force: return false
	set_collision_layer_value(EnemyLayer.ACTIVE, false)
	set_collision_layer_value(EnemyLayer.DYING, true)
	set_collision_mask_value(EnemyLayer.ACTIVE, false)
	state = EnemyState.KNOCKBACK
	knockback_dir = (position - attack_pos).normalized()
	delete_timer.start()
	think_tick.stop()
	jump_timer.stop()
	_on_die()
	velocity = KNOCKBACK_SPEED * knockback_dir
	GameEvents.enemy_died.emit()
	return true

func _physics_process(delta):
	bumped_this_frame = move_and_slide()

	match state:
		EnemyState.ALIVE: _on_think()
		EnemyState.HOPPINGOVER: velocity.y += JUMP_GRAVITY * delta
		EnemyState.ENTERING: 
			var speed_x_sign: float = 1.0 if jumps_on_left else -1.0
			velocity = Vector2(ENTER_SPEED * speed_x_sign, 0.0)
		EnemyState.KNOCKBACK when bumped_this_frame:
			state = EnemyState.OFFSCREEN
			GameEvents.shake.emit(1.0, false)
			# Don't collide with the level
			set_collision_mask_value(1, false)
			var hit: HitEnemy = hitspark.instantiate()
			hit.be_quiet = die_quiet
			hit.position = position + knockback_dir * 16.0
			add_sibling(hit)
			var offscreen_dir_angle: float = OFFSCREEN_DELTA * float(die_angle_sign)
			velocity = 1.6 * KNOCKBACK_SPEED * knockback_dir.rotated(offscreen_dir_angle)

func _on_jump_zone():
	if state != EnemyState.ENTERING: return
	var speed_x_sign: float = 1.0 if jumps_on_left else -1.0
	velocity = JUMP_VELOCITY * Vector2(speed_x_sign, 1.0)
	state = EnemyState.HOPPINGOVER
	jump_timer.start()
	_on_jump()
	hop.play()

func _jump_done():
	set_collision_mask_value(1, true)
	var k = 1.0 + 0.5 * randi_range(0, 3)
	think_tick.start(think_time * k)
	
	state = EnemyState.ALIVE
	velocity = Vector2.ZERO
	_on_think_ready()
	_update_think()

func _lifetime_out():
	GameEvents.enemy_despawned.emit()
	queue_free()

func _update_think():
	if state != EnemyState.ALIVE: return
	var k = 1.0 + 0.5 * randi_range(0, 3)
	think_tick.start(think_time * k)
	_on_think_update()
	set_collision_mask_value(EnemyLayer.ACTIVE, randi_range(0, 2) == 2)
