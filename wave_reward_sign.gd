class_name WaveReward extends Label

signal reward_appeared(score_delta: int)

@onready var timer = $Timer

@export var score_delta: int

const DELTA: float = -256.0

func _done():
	reward_appeared.emit(score_delta)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var t = elastic((1.0 - timer.time_left / timer.wait_time))
	position.y = -53 + -256 * t
	
func elastic(x: float) -> float:
	return -sin(1.5 * x * PI) * (sub_elastic(x) / sub_elastic(1))
	
func sub_elastic(x: float) -> float:
	return pow(2.5, 1.5 * (x - 1.0))
