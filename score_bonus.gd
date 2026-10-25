class_name ScoreBonus extends Area2D

func _picked_up(node: Node2D):
	if node is Player: node._on_score_bonus_pickup(self)
	queue_free()
