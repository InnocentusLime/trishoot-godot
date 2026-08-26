class_name GunUpgrade extends Area2D

func _picked_up(node: Node2D):
	if node is Player: node._on_gun_upgrade_pickup(self)
	queue_free()
