extends Node

var player_pos: Vector2
var player_hp: int
var mult: int

signal shake(acc: float, setter: bool)
signal score_mult_changed(mult: int)
signal demo_over
