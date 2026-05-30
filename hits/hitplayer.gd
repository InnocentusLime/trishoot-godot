extends Sprite2D

const SCALE_SPEED: float = 4.0
const MAX_SCALE: float = 2.0
const SHAKE_AMPLITUDE: float  = 16.0
const APPEAR_TIME: float = 0.16

var t: float = 0.0
@onready var max_time: float = $Visibility.wait_time
@onready var pain: AudioStreamPlayer2D = $Pain

func _enter_tree():
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	var k = min(t / APPEAR_TIME, 1.0)
	scale = Vector2(1.0, 1.0) * min(pow(SCALE_SPEED, k), MAX_SCALE)
	var shake_angle: float = randf() * (2*PI)
	
	var ampl = SHAKE_AMPLITUDE * (1.0 - 0.999*k)
	offset = Vector2.from_angle(shake_angle) * ampl 
	
func _hide():
	visible = false
	get_tree().paused = false
	GameEvents.player_hit.emit()
