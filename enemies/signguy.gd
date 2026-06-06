extends Think

const WALK_SPEED: float = 100.0

var walk_dir: Vector2 = Vector2.ZERO
var walk_rot: float = 0.0

func _die(): GameEvents.game_start.emit()

func _think(bumped: bool): velocity = Vector2.ZERO

func _update_think(): pass
