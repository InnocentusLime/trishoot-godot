class_name HitEnemy extends Sprite2D

@export var be_quiet: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if be_quiet: $HitPlayer.stop()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
