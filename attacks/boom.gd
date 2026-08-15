extends Node2D

func _ready():
	var power = scale.x
	$Shoot.pitch_scale = pow(2.0, 1.6 - power)
	$Shoot.volume_db = power * power
	$AnimationPlayer.current_animation = "boom"
