extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _on_body_entered(body):
	if not sprite.visible: return
	$Cock.play()
	sprite.visible = false
	label.visible = false
