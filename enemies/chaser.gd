extends Think

const WALK_SPEED: float = 100.0

var walk_dir: Vector2 = Vector2.ZERO
var walk_rot: float = 0.0

func _think(bumped: bool):
	var dir = (GameEvents.player_pos - position).normalized()
	if bumped:
		walk_dir = walk_dir.rotated(PI / 8.0)
	walk_dir = dir.rotated(walk_rot)
	velocity = WALK_SPEED * walk_dir

func _update_think():
	var increment = randi_range(-3, 3)
	walk_rot = float(increment)*1.5 * PI / 8.0
