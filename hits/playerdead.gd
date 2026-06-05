extends Node2D

@onready var die: AudioStreamPlayer2D = $Die

const FLY_SPEED: float = 800.0

enum State {FLYING=0, LANDING=1}

var state: State = State.FLYING

# Called when the node enters the scene tree for the first time.
func _ready():
	$Flop.play()

func _on_fly_done():
	state = State.LANDING
	position = Vector2(480, -128)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(480, 282.2), 0.7) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_IN)
	tween.tween_callback(_land_done)
	$FlySpr.visible = false
	$LandSpr.visible = true
	
func _land_done():
	die.play()
	$Label.visible = true
	print("oops")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == State.FLYING:
		position.y -= FLY_SPEED * delta
