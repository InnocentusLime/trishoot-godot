extends CharacterBody2D

@onready var weapon: Node2D = $Weapon
@onready var weaponSprite: Sprite2D = $Weapon/Weapon
@onready var center: Vector2 = $MapCol.shape.get_rect().size / 2.0
@onready var body: Sprite2D = $Body
@onready var shoot: AudioStreamPlayer2D = $Shoot

@export var boom: PackedScene
@export var recoil_acc: float = 1.0

const SPEED = 164.0
const KNOCKBACK_SPEED = 666.0
const WEAPON_DIST = 24.0
const BOOM_DIST = 24.0

var aim_angle: float = 0.0
var face_right: bool = false
var shooting: bool = false
var recoiling: bool = false

func _ready():
	$AnimationPlayer.current_animation = "running"

func _physics_process(delta):
	if recoiling:
		var k = ease(recoil_acc, 0.4)
		velocity = -Vector2.from_angle(aim_angle) * KNOCKBACK_SPEED * k
	else:
		velocity = Vector2.ZERO
		
	if shooting:
		move_and_slide()
		return
		
	var h_dir = Input.get_axis("ui_left", "ui_right")
	var v_dir = Input.get_axis("ui_up", "ui_down")
	velocity = Vector2(h_dir, v_dir).normalized() * SPEED

	if velocity:
		if face_right:
			$AnimationPlayer.current_animation = "running_right"
		else:
			$AnimationPlayer.current_animation = "running_left"
		$AnimationPlayer.speed_scale = 1.0
	elif Input.is_action_just_pressed("ui_accept"):
		shooting = true
		recoiling = true
		velocity = -Vector2.from_angle(aim_angle) * KNOCKBACK_SPEED
		$AnimationPlayer.current_animation = "shoot_left"
		var the_boom: Node2D = boom.instantiate()
		var weapon_angle: float = aim_angle - PI
		the_boom.position = position + center - Vector2.from_angle(weapon_angle) * (WEAPON_DIST + BOOM_DIST)
		the_boom.rotation = weapon_angle
		add_sibling(the_boom)
		shoot.play()
	else:
		if face_right:
			$AnimationPlayer.current_animation = "idle_right"
		else:
			$AnimationPlayer.current_animation = "idle_left"
		$AnimationPlayer.speed_scale = 1.0
	
	move_and_slide()
	
#func ease(x: float) -> float:
	#return 1 - pow(2.0, -10 * x)
	
func _process(delta):
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
