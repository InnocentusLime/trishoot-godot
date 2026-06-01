class_name Boom
extends Node2D

@onready var hitbox = $Damge

var processed: bool = false

func _ready():
	$AnimationPlayer.current_animation = "boom"
	
func _physics_process(delta):
	# Await next frame so the area can fetch all stuff
	await get_tree().physics_frame
	if processed: return
	
	var to_dmg_list: Array[Node2D] = hitbox.get_overlapping_bodies()
	for to_dmg in to_dmg_list:
		if to_dmg.has_method("_on_dmg"):
				print("calling")
				to_dmg.call("_on_dmg", position)
	processed = true
	GameEvents.player_comboed.emit(to_dmg_list.size())
