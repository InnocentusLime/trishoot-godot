extends Node

var player_pos: Vector2

signal shake(acc: float, setter: bool)
signal score_changed(delta: int, label: String)
signal player_comboed(combo_size: int)
signal enemy_died
signal enemy_despawned
signal game_start
signal game_over
