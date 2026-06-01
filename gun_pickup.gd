extends Area2D

func _on_body_entered(body):
	queue_free()
	GameEvents.game_start.emit()
