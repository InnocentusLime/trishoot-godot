extends Node

func _on_signbot_killed():
	$WaveManger.start_wave()
