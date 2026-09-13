extends Node

var player_pos: Vector2

signal shake(acc: float, setter: bool)
signal score_changed(delta: int, label: String)
signal demo_over
