extends Node

func _on_signbot_killed():
	$WaveManger.start_wave()

func _on_player_die():
	$WaveManger.stop_wave()
	get_tree().call_group("enemies", "_on_dmg", Vector2(480, 282.2), 9999, true)

func _process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
