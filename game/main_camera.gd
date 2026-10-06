class_name MainCamera
extends Camera2D

const SHAKE_AMPLITUDE: float = 1.0

var shake_koeff: float = 0.0

func _ready():
	GameEvents.shake.connect(_on_shake)

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
	offset = Vector2.from_angle(shake_angle) * ampl
