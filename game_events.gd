extends Node

var player_pos: Vector2

signal shake(acc: float, setter: bool)

signal player_comboed(combo_size: int)
signal enemy_died
signal wave_complete
signal wave_start
signal enemy_despawned
signal game_start
signal game_over
