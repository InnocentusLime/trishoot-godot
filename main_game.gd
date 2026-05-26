extends Node2D

const SHAKE_AMPLITUDE: float = 1.0
const BASE_SCORE: int = 10

@onready var game_camera: Camera2D = $WindowManager/Camera2D

var score: int = 0
var shake_koeff: float = 0.0

func _on_combo(count: int):
	var reward: int = (count*count) * BASE_SCORE 
	score += reward
	prints("COMBO", count, "REWARD", reward)

func _on_enemy_hit_bounds():
	shake_koeff += 1.0
	
func _on_player_shoot():
	if shake_koeff < 1.0:
		shake_koeff += (1.0 - shake_koeff)
		
func _on_player_hit():
	shake_koeff = 6.0

func _process(delta):
	var boost: float
	if shake_koeff <= 4.0:
		boost = max(1.0, pow(4.0, floor(shake_koeff)))
	else:
		boost = max(1.0, pow(2.0, floor(shake_koeff * 0.8)))
	shake_koeff -= delta * boost
	shake_koeff = max(0.0, shake_koeff)
	
	var shake_angle: float = randf() * (2*PI)
	game_camera.offset = Vector2.from_angle(shake_angle) * (SHAKE_AMPLITUDE * shake_koeff)
