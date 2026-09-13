class_name Explosion
extends Node2D

@export var quiet: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer2D.volume_linear = 0.1
	$AnimatedSprite2D.play("default")
	GameEvents.shake.emit(3.0, false)
