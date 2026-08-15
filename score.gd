class_name Bonus extends Area2D

@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound
@onready var graphics: Sprite2D = $Sprite

var picked_up: bool = false

func _picked_up(node: Node2D):
	if picked_up: return
	GameEvents.score_changed.emit(100, "YUM!")
	pickup_sound.play()
	graphics.visible = false
	picked_up = true
	if node is Player: node._on_bonus_pickup(self)
	
