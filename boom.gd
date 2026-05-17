extends Node2D

func _ready():
	print("boom")
	$AnimationPlayer.current_animation = "boom"

func _on_done():
	queue_free()
