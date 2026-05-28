class_name ComboShower
extends Label

signal reward_appeared(value: int)

@onready var timer: Timer = $Timer

var combo_size: int
var score: int
var value: int
var orig_y: float
var start: Vector2
var end: Vector2

func _timer_finished():
	reward_appeared.emit(value)
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	start = global_position
	orig_y = position.y
	value = combo_size * score
	text = "%d x %d" % [score, combo_size]
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var time = 1.0 - timer.time_left / timer.wait_time
	if time <= 1.0:
		time += delta
		var t = elastic(time)
		position.y = orig_y + lerpf(0, end.y - start.y, t)

func elastic(x: float) -> float:
	return -sin(1.5 * x * PI) * (sub_elastic(x) / sub_elastic(1))
	
func sub_elastic(x: float) -> float:
	return pow(2.5, 1.5 * (x - 1.0))
