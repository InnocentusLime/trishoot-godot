class_name MainGame extends Node2D

const SHAKE_AMPLITUDE: float = 1.0

@onready var game_camera: Camera2D = $Gameplay
@onready var music: AudioStreamPlayer = $Music

@export var die: PackedScene

var score: int = 0
var shake_koeff: float = 0.0
var restart_locked: bool

func _ready():
	GameEvents.shake.connect(_on_shake)
	GameEvents.score_changed.connect(_on_score_changed)
	GameEvents.game_over.connect(_on_game_over)
	GameEvents.demo_over.connect(_on_demo_over)
	
func _on_demo_over():
	restart_locked = false
	get_tree().create_tween() \
		.tween_property(music, "volume_linear", 0.0, 2.0)
	
func _on_game_over():
	music.stop()
	restart_locked = false
	
	var dieanim: PlayerDead = die.instantiate()
	dieanim.position = GameEvents.player_pos
	dieanim.score = score
	add_child(dieanim)

func _on_sign_bot_killed():
	music.play()

func _on_score_changed(score_delta: int, _score_label: String):
	score += score_delta
	
func _on_shake(acc: float, setter: bool):
	if setter: shake_koeff = acc
	else: shake_koeff += acc

func _process(delta):
	var boost: float
	if shake_koeff <= 4.0:
		boost = max(1.0, pow(4.0, floor(shake_koeff)))
	else:
		boost = max(1.0, pow(2.0, floor(shake_koeff * 0.8)))
	shake_koeff -= delta * boost
	shake_koeff = max(0.0, shake_koeff)
	
	var shake_angle: float = randf() * (2*PI)
	var ampl = SHAKE_AMPLITUDE * shake_koeff * shake_koeff
	game_camera.offset = Vector2.from_angle(shake_angle) * ampl
	
	if Input.is_action_just_pressed("restart") and not restart_locked:
		get_tree().reload_current_scene()
