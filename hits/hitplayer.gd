extends Sprite2D

const SCALE_SPEED: float = 4.0
const MAX_SCALE: float = 2.0
const SHAKE_AMPLITUDE: float  = 1.0
var t: float = 0.0
@onready var max_time: float = $Timer.wait_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	var k = min(t / (0.7 * max_time), 1.0)
	scale = Vector2(1.0, 1.0) * min(pow(SCALE_SPEED, k), MAX_SCALE)
	var shake_angle: float = randf() * (2*PI)
	var ampl = SHAKE_AMPLITUDE * k
	offset = Vector2.from_angle(shake_angle) * ampl 
