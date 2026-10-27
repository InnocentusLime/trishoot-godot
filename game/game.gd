extends Node

signal combo_level_changed(new_val: int)

@onready var ui: GameUI = $MainCamera/UI
@onready var combo_timer: Timer = $ComboTimer
@export var dead: PackedScene

const BASE_SCORE: int = 10
const BONUS_COST: int = 20
 
var total_score: int
var this_wave_score: int
var player_hp: int
var mult: int = 1:
	set(val):
		if val <= 0: mult = 1
		else: mult = val
		GameEvents.score_mult_changed.emit(val)
		GameEvents.mult = val
var combo_level: int = 0:
	set(val): 
		combo_level = val
		combo_level_changed.emit(val)
		mult = int(float(combo_level)/10.0)

func _on_bonus_pickup():
	var reward = BONUS_COST * (mult*mult)
	this_wave_score += reward
	total_score += reward
	ui.show_bonus_reward(reward)

func _on_combo_timeout():
	combo_level -= 1
	if combo_level > 0:
		combo_timer.start(get_combo_decay(combo_level))
	
func get_combo_decay(lvl: int) -> float:
	return 1.0 + pow(2.0, -float(lvl)/3.0)

func _on_player_hp_change(new_val: int):
	player_hp = new_val
	GameEvents.player_hp = new_val

func _on_enemies_killed(amount: int):
	var reward = amount*BASE_SCORE
	this_wave_score += reward
	total_score += reward
	ui.show_kill_reward(amount, reward)
	
	combo_level = max(combo_level, amount)
	var k := float(amount)/float(combo_level)
	var dec := get_combo_decay(combo_level)
	var new_time := minf(combo_timer.time_left+k*dec, dec)
	combo_timer.start(new_time)

func _on_wave_finished():
	if player_hp <= 1: return
	var reward = player_hp*this_wave_score
	this_wave_score = 0
	total_score += reward
	ui.show_wave_reward(player_hp, reward)

func _on_signbot_killed():
	$WaveManger.start_wave()
	$Music.play()

func _on_player_die():
	$WaveManger.stop_wave()
	$Music.stop()
	get_tree().call_group("enemies", "_on_dmg", Vector2(480, 282.2), 9999, true)
	var dead_obj: PlayerDead = dead.instantiate()
	dead_obj.position = GameEvents.player_pos
	dead_obj.score = total_score
	add_child(dead_obj)

func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _on_demo_over():
	get_tree().create_tween() \
		.tween_property($Music, "volume_linear", 0.0, 2.0)
