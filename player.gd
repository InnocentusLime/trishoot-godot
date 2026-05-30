extends CharacterBody2D

@onready var weapon: Node2D = $Weapon
@onready var weaponSprite: Sprite2D = $Weapon/Weapon
@onready var center: Vector2 = $MapCol.shape.get_rect().size / 2.0
@onready var body: Sprite2D = $Body
@onready var shoot: AudioStreamPlayer2D = $Shoot

@export var boom: PackedScene
@export var hitspark: PackedScene
@export var recoil_acc: float = 1.0

const SPEED = 164.0
const KNOCKBACK_SPEED = 666.0
const WEAPON_DIST = 24.0
const BOOM_DIST = 24.0
const FLICKER_SPEED = 20.0 / 1.0 # flick / s
const INVINCE_TIME = 3.0

var hp: int = 3
var aim_angle: float = 0.0
var face_right: bool = false
var shooting: bool = false
var recoiling: bool = false
var invince_left: float = 0.0

func _on_dmg(hitpos: Vector2):
	if invince_left > 0.0: return
	hp -= 1
	invince_left = INVINCE_TIME
	if hp <= 0:
		queue_free()
		return
	var hit_dir: Vector2 = (hitpos - position).normalized()
	var hit: Node2D = hitspark.instantiate()
	hit.position = position + hit_dir * 16.0
	add_sibling(hit)

func _ready():
	$AnimationPlayer.current_animation = "idle_left"

func _physics_process(delta):
	var h_dir = Input.get_axis("move_left", "move_right")
	var v_dir = Input.get_axis("move_up", "move_down")
	var move_vel = Vector2(h_dir, v_dir).normalized() * SPEED
	
	velocity = Vector2.ZERO
	if recoiling:
		var knock_dir = -Vector2.from_angle(aim_angle)
		var k = ease(recoil_acc, 0.4)
		move_vel *= (1 - k) * 0.8
		var dot = move_vel.dot(knock_dir)
		if dot > 0.0: move_vel -= dot * knock_dir
		velocity += knock_dir * KNOCKBACK_SPEED * k
	elif shooting:
		move_vel *= 0.8
	velocity += move_vel
		
	if shooting:
		move_and_slide()
		return

	var animation: StringName
	if face_right:
		animation = "idle_right"
	else:
		animation = "idle_left"
	if velocity:
		if face_right:
			animation = "running_right"
		else:
			animation = "running_left"
	if Input.is_action_just_pressed("shoot"):
		shooting = true
		recoiling = true
		velocity = -Vector2.from_angle(aim_angle) * KNOCKBACK_SPEED
		animation = "shoot_left"
		var the_boom: Node2D = boom.instantiate()
		var weapon_angle: float = aim_angle - PI
		the_boom.position = position + center - Vector2.from_angle(weapon_angle) * (WEAPON_DIST + BOOM_DIST)
		the_boom.rotation = weapon_angle
		add_sibling(the_boom)
		shoot.play()
		GameEvents.player_gun_shot.emit()
	$AnimationPlayer.current_animation = animation
	
	move_and_slide()
	
#func ease(x: float) -> float:
	#return 1 - pow(2.0, -10 * x)
	
func _process(delta):
	GameEvents.player_pos = position
		
	if invince_left > 0:
		invince_left -= delta
		var current_flicker = int(invince_left * FLICKER_SPEED)
		if current_flicker % 2 == 0: 
			modulate = pain_color()
		else: 
			modulate = Color.TRANSPARENT
	else: modulate = Color.WHITE
	
	if shooting:
		return
	
	var m: Vector2 = get_global_mouse_position()
	var o: Vector2 = position + center
	aim_angle = (m - o).angle()
	face_right = abs(rad_to_deg(aim_angle)) < 90
	
	var weapon_angle: float = aim_angle - PI
	weapon.position = center - Vector2.from_angle(weapon_angle) * WEAPON_DIST
	weapon.rotation = weapon_angle

	if face_right:
		weaponSprite.offset = Vector2i(0, -4)
	else:
		weaponSprite.offset = Vector2i(0, 0)
	weaponSprite.flip_v = face_right

func _on_recoil_stop():
	recoiling = false

func _on_shoot_done():
	shooting = false
	
func pain_color() -> Color:
	var k = 1.0 - invince_left / INVINCE_TIME
	k = min(curve(k * 4.0) / curve(1), 1.0)
	return Color(1.0, k, k)
	
func curve(x: float) -> float:
	return pow(4.0, x) - 1
