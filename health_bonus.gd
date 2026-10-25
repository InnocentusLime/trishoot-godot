class_name HealthBonus extends Area2D

func _picked_up(node: Node2D):
	if node is Player: node._on_health_bonus_pickup(self)
	queue_free()
