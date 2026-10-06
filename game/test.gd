extends Node2D

const SHAKE_AMPLITUDE: float = 1.0

@onready var game_camera: Camera2D = $Gameplay

@export var die: PackedScene

var score: int = 0
var shake_koeff: float = 0.0
var restart_locked: bool

func _on_player_death():
	get_tree().call_group("enemies", "_on_dmg", Vector2(480, 282.2), 9999, true)
