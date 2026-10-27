class_name ScoreBonus extends Area2D

func _ready():
	_on_mult_change(GameEvents.mult)
	GameEvents.score_mult_changed.connect(_on_mult_change)

func _on_mult_change(val: int):
	var k := 1.0 + 0.6 * (pow(2, float(val-1)) - 1)
	scale = Vector2(k, k)

func _picked_up(node: Node2D):
	if node is Player: node._on_score_bonus_pickup(self)
	queue_free()
