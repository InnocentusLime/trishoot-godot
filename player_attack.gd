class_name PlayerAttack extends Area2D

@onready var block_sound: AudioStreamPlayer2D = $BlockSound

const BASE_SCORE: int = 10
const PUNISH: int = -100

func attack(level: int):
	var damaged := 0
	var blocked := 0
	var to_dmg_list: Array[Node2D] = get_overlapping_bodies()
	for to_dmg in to_dmg_list:
		if to_dmg is Enemy:
			if to_dmg._on_dmg(global_position, level):
				damaged += 1
			else:
				blocked += 1
	
	var to_dmg_list2: Array[Area2D] = get_overlapping_areas()
	for to_dmg in to_dmg_list2:
		var parent: Node2D = to_dmg.get_parent()
		if parent == null: continue
		if parent.has_method("_on_dmg"):
				parent.call("_on_dmg", global_position)
				
	if blocked > 0:
		block_sound.play()
				
	var score_delta: int = PUNISH
	var score_comment: String = "You suck"
	if damaged != 0:
		score_delta = get_score(damaged)
		score_comment = get_comment(damaged)
	elif to_dmg_list2.size() > 0: # Grace for the projectile parrying
		score_delta /= 2 
	GameEvents.score_changed.emit(score_delta, "%s %d" % [score_comment, score_delta])

func get_score(n: int) -> int:
	var mult: float = floor(exp(floor(n + 1) / 2.0)) 
	return BASE_SCORE * int(mult)
	
func get_comment(n: int) -> String:
	n = min(n, comments.size() - 1)
	return comments[n]
	
var comments: Array[String] = [
	"NO!",
	"Meh",
	"Okay",
	"Not bad",
	"Nice!",
	"OH SHIT!!"
]
