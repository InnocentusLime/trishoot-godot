class_name GameUI
extends CanvasLayer

@export var score: Control
@export var score_label: Label
@export var hp: Health
@export var comboer: Control
@export var wave_rewarder: Control
@export var combo: Label

@export var combo_widget: PackedScene
@export var wave_reward_widget: PackedScene

var current_score = 0
var score_distort = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	score_label.text = "Score: %d" % current_score
	
func _on_demo_over():
	get_tree().create_tween()\
		.tween_property($DemoOver, "modulate", Color.WHITE, 3.0)
	
func _on_player_dead():
	$HUD.visible = false

func _on_combo_level_change(new_val: int):
	if new_val == 0 or new_val == 1: combo.text = ""
	else: combo.text = "X %d" % new_val

func _on_player_hp_change(new_hp: int):
	hp.set_value(new_hp)

func show_kill_reward(amount: int, delta: int):
	var combo: ComboShower = combo_widget.instantiate()
	combo.end = score.global_position
	combo.score_delta = delta
	combo.score_label = " KILLED!"
	combo.reward_appeared.connect(_on_reward_shown)
	comboer.add_child(combo)
	
func show_bonus_reward(delta: int):
	var combo: ComboShower = combo_widget.instantiate()
	combo.end = score.global_position
	combo.score_delta = delta
	combo.score_label = " BONUS!"
	combo.reward_appeared.connect(_on_reward_shown)
	comboer.add_child(combo)
	
func show_wave_reward(mult: int, delta: int):
	var wave_reward: WaveReward = wave_reward_widget.instantiate()
	wave_reward.text = "WOW WAVE FINISHED! x %d" % mult
	wave_reward.score_delta = delta
	wave_reward.reward_appeared.connect(_on_reward_shown)
	wave_rewarder.add_child(wave_reward)

func _on_reward_shown(score_delta):
	current_score += score_delta
	score_distort = 1.0
	score_label.text = "Score: %d" % current_score

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var k = 1.0 + elastic(score_distort)
	score_label.scale = Vector2(k, k)
	score_distort = max(0.0, score_distort - delta*4.0)
	
func elastic(x: float) -> float:
	return 256.0/27.0 * x * pow(1 - x, 3.0)
