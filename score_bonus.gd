class_name ScoreBonus extends Area2D

func _picked_up(node: Node2D):
	GameEvents.score_changed.emit(100, "YUM!")
	queue_free()
	if node is Player: node._on_score_bonus_pickup(self)
