extends Node

var player_pos: Vector2

signal shake(acc: float, setter: bool)
signal score_changed(delta: int, label: String)
signal combo(size: int)
signal demo_over
