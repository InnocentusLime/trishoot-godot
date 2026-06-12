class_name PlayerDead
extends Node2D

@onready var die: AudioStreamPlayer = $Die

const FLY_SPEED: float = 800.0

enum State {FLYING=0, LANDING=1}

var state: State = State.FLYING
var score: int

# Called when the node enters the scene tree for the first time.
func _ready():
	$Flop.play()
	$AnimationPlayer.current_animation = "fly"
	GameEvents.shake.emit(6, true)

func _on_fly_done():
	state = State.LANDING
	$AnimationPlayer.current_animation = "flop"
	position = Vector2(480, -230)
	
func _land_done():
	$OverText.visible = true
	$OverText/Score.text = "Score: %d" % score
	
func _land_shake():
	GameEvents.shake.emit(2, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == State.FLYING:
		position.y -= FLY_SPEED * delta
