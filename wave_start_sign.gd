class_name WaveStart extends Label

@onready var timer = $Timer

const DELTA: float = -256.0

func _done():
	GameEvents.wave_start.emit()
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var t = elastic((1.0 - timer.time_left / timer.wait_time))
	position.y = -53 + -256 * t
	
func elastic(x: float) -> float:
	return -sin(1.5 * x * PI) * (sub_elastic(x) / sub_elastic(1))
	
func sub_elastic(x: float) -> float:
	return pow(2.5, 1.5 * (x - 1.0))
