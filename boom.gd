extends Node2D

@onready var hitbox = $Damge

var processed: bool = false

func _ready():
	$AnimationPlayer.current_animation = "boom"
	
func _physics_process(delta):
	if processed: return
	
	var to_dmg_list: Array[Node2D] = hitbox.get_overlapping_bodies()
	for to_dmg in to_dmg_list:
		if to_dmg.has_method("_on_dmg"):
				to_dmg.call("_on_dmg", position)
	processed = true

func _on_done():
	queue_free()
