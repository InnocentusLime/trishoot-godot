extends Sprite2D

var lifetime: float = 0.1

func _process(delta):
	if lifetime <= 0.0: queue_free()
	lifetime -= delta
