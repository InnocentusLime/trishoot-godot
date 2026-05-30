extends Node2D

const WALK_SPEED: float = 40.0

func _think(body: CharacterBody2D, player: AnimationPlayer):
	var dir = (GameEvents.player_pos - body.position).normalized()
	body.velocity = WALK_SPEED * dir
