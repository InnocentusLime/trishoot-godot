class_name Player extends CharacterBody2D

signal player_hp_change(new_val: int)
signal combo_life_changed(new_val: float)
signal combo_level_changed(new_val: int)

enum State {IDLE=0, RUNNING=1, SHOOTING=2}

const SPEED = 164.0
const KNOCKBACK_SPEED = 666.0
const WEAPON_DIST = 8.0
const BOOM_DIST = 24.0
const FLICKER_SPEED = 20.0 / 1.0 # flick / s
const BAR_SIZE = 240

@onready var weapon: Node2D = $Weapon
@onready var weaponSprite: Sprite2D = $Weapon/Weapon
@onready var invince: Timer = $Invince
@onready var anims: AnimationPlayer = $AnimationPlayer
@onready var walk_hints: Sprite2D = $Hints
@onready var weapon_muzzle: Node2D = $Weapon/Muzzle
@onready var attack_pivot: Node2D = $Weapon/AttackPivot
@onready var attack: PlayerAttack = $Weapon/AttackPivot/Attack
@onready var damage_hint: Node2D = $Weapon/AttackPivot/Attack/DamageHint
@onready var body: Sprite2D = $Sprite
@onready var gun_upgrade_pickup: AudioStreamPlayer2D = $BonusSounds/GunUpgradePickup
@onready var score_bonus_pickup: AudioStreamPlayer2D = $BonusSounds/ScoreBonusPickup

@export var boom: PackedScene
@export var hitspark: PackedScene
@export var die: PackedScene
@export var recoil_acc: float = 0.0
@export var hint_life: float = 1.5

@export var hasgun: bool = false
@export var god: bool = false
@export var shot_cost: float = 1.0
@export var bonus_cost: float = 1.0
@export var combo_scale: Array[Vector2]

var state: State = State.IDLE
var hp: int = 3
var aim_angle: float = 0.0
var face_right: bool = false
var walk_time: float = 0.0
var combo_points: int:
	set(val):
		combo_points = clamp(val, 0, max_combo_points)
		combo_life_changed.emit(float(combo_points % BAR_SIZE) / float(BAR_SIZE))
		if combo_points == 0:
			combo_level_changed.emit(0)
		else:
			combo_level_changed.emit(combo_points / BAR_SIZE + 1)

var levels: Array[LevelEntry] = [
	LevelEntry.new(3, 1),
	LevelEntry.new(3, 2),
	LevelEntry.new(3, 8),
	LevelEntry.new(1, 15),
]
var max_combo_points: int = levels.size()*BAR_SIZE

class LevelEntry:
	var shots: int
	var bonuses_per_level: int
	
	func _init(shots, bonuses_per_level):
		self.shots = shots
		self.bonuses_per_level = bonuses_per_level
	
	func shot_cost() -> int: return BAR_SIZE / shots
	func bonus_cost() -> int: return shot_cost() / bonuses_per_level

func _on_gun_upgrade_pickup(pickup: Node2D):
	gun_upgrade_pickup.play()
	var cost := get_bonus_cost()
	combo_points += cost

func _on_score_bonus_pickup(pickup: Node2D):
	score_bonus_pickup.play()

func _on_dmg(hitpos: Vector2):
	if !invince.is_stopped(): return
	invince.start()
	
	if not god: hp -= 1
	if hp <= 0: 
		GameEvents.game_over.emit()
		queue_free()
	
	player_hp_change.emit(hp)
	GameEvents.shake.emit(10.0, true)
	
	var hit: PlayerHit = hitspark.instantiate()
	hit.fatal = hp <= 0
	hit.position = position
	add_sibling(hit)

func _ready():
	$AnimationPlayer.current_animation = "idle_left"
	player_hp_change.emit(hp)
	combo_level_changed.emit(0)
	combo_life_changed.emit(0)
	if hasgun: weapon.visible = true

func _on_gun_pickup(_body: Node2D):
	walk_hints.visible = false
	weapon.visible = true
	hasgun = true

func _physics_process(delta):
	var h_dir = Input.get_axis("move_left", "move_right")
	var v_dir = Input.get_axis("move_up", "move_down")
	var move_vel = Vector2(h_dir, v_dir).normalized() * SPEED
	
	velocity = Vector2.ZERO
	if state == State.SHOOTING and recoil_acc >= 0.00001:
		var knock_dir = -Vector2.from_angle(aim_angle)
		move_vel *= (1 - recoil_acc) * 0.8
		var dot = move_vel.dot(knock_dir)
		if dot > 0.0: move_vel -= dot * knock_dir
		var combo_level := get_combo_level()
		velocity += knock_dir * KNOCKBACK_SPEED * (recoil_acc * (combo_level*0.5 + 0.5))
	elif state == State.SHOOTING:
		move_vel *= 0.8
	velocity += move_vel
		
	move_and_slide()
	
func _process(delta: float):
	GameEvents.player_pos = position
	damage_hint.visible = hasgun and state != State.SHOOTING
	
	attack_pivot.scale = combo_scale[get_combo_level()]
	
	if state == State.RUNNING: walk_time += delta
	if walk_time >= hint_life: walk_hints.visible = false
	
	if !invince.is_stopped():
		var current_flicker = int(invince.time_left * FLICKER_SPEED)
		if current_flicker % 2 == 0: set_color(pain_color())
		else: set_color(Color.TRANSPARENT)
	else: set_color(Color.WHITE)
	
	if state == State.SHOOTING: return
	
	var m: Vector2 = get_global_mouse_position()
	var o: Vector2 = position
	aim_angle = (m - o).angle()
	var new_face_right = abs(rad_to_deg(aim_angle)) < 90
	
	var weapon_angle: float = aim_angle - PI
	weapon.position = -Vector2.from_angle(weapon_angle) * WEAPON_DIST
	weapon.rotation = weapon_angle
	
	if Input.is_action_just_pressed("shoot") and hasgun: 
		shoot()
		enter_state(State.SHOOTING, new_face_right)
	elif velocity: enter_state(State.RUNNING, new_face_right)
	else: enter_state(State.IDLE, new_face_right)
	
func pain_color() -> Color:
	var k = 1.0 - invince.time_left / invince.wait_time
	k = min(curve(k * 4.0) / curve(1), 1.0)
	return Color(1.0, k, k)
	
func curve(x: float) -> float:
	return pow(4.0, x) - 1

func _on_animation_finished(anim_name: StringName):
	if anim_name == "shoot_left": enter_state(State.IDLE, face_right, true)

func enter_state(new_state: State, new_face_right: bool, force: bool = false):
	if state == State.SHOOTING and not force: return
	if state == new_state and new_face_right == face_right: return
	
	var animation: StringName
	match new_state:
		State.IDLE when new_face_right: animation = "idle_right"
		State.IDLE: animation = "idle_left"
		State.RUNNING when new_face_right: animation = "running_right"
		State.RUNNING: animation = "running_left"
		State.SHOOTING: animation = "shoot_left"
	state = new_state
	anims.current_animation = animation
	face_right = new_face_right
	
	if face_right: weaponSprite.offset = Vector2i(0, -4)
	else: weaponSprite.offset = Vector2i(0, 0)
	weaponSprite.flip_v = face_right

func shoot():
	attack.attack(get_combo_level())
	var combo_level := get_combo_level()
	var the_boom: Node2D = boom.instantiate()
	var weapon_angle: float = aim_angle - PI
	the_boom.position = weapon_muzzle.global_position
	the_boom.rotation = weapon_angle
	the_boom.scale = combo_scale[combo_level]
	#weapon.add_child(the_boom)
	add_sibling(the_boom)
	GameEvents.shake.emit(combo_level+1, false)
	
	combo_points -= get_shot_cost()

func get_bonus_cost() -> int:
	var level := get_combo_level()
	if level == 0: return levels[0].bonus_cost()
	return levels[level-1].bonus_cost()

func get_shot_cost() -> int:
	var level := get_combo_level()
	if level == 0: return 0
	return levels[level-1].shot_cost()

func get_combo_level() -> int:
	if combo_points == 0: return 0
	return (combo_points / BAR_SIZE) + 1

func set_color(c: Color):
	body.modulate = c
	weaponSprite.modulate = c
