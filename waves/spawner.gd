# Timer properties:
# Autostart: false
# Oneshot: false
class_name Spawner extends Timer

const CENTER_X: float = 450

@export var spawn_point: WaveTypes.SpawnPoint = WaveTypes.SpawnPoint.TEST
@export var to_spawn: PackedScene
@export var enemy_budget: int = 1
@export var enemy_cap: int = 1
@export var enemy_offsets: Array[Vector2] = [Vector2(0.0, 0.0)]

@export_group("Spawner dependency")
@export var to_track: Spawner
@export var enable_on_budget: int

var spawn_pos: Vector2
var enter_dir: Vector2
var alive_enemies: int

func _enter_tree(): start()

func _on_spawn():
	if to_track != null:
		if to_track.enemy_budget > enable_on_budget: return
		
	for enemy_offset in enemy_offsets:
		spawn_enemy(enemy_offset)
		
func spawn_enemy(off: Vector2):
	if enemy_budget <= 0 or alive_enemies >= enemy_cap: 
		return

	var enemy: Enemy = to_spawn.instantiate()
	enemy.position = spawn_pos + off
	enemy.enter_dir = enter_dir
	enemy.killed.connect(_on_enemy_die)
	enemy.tree_exiting.connect(_on_enemy_despawn)
	get_tree().root.add_child(enemy)
	alive_enemies += 1
	enemy_budget -= 1
	
	if enemy_budget <= 0 or alive_enemies >= enemy_cap: 
		stop()
	
func _on_enemy_die():
	alive_enemies -= 1
	if enemy_budget > 0 and is_stopped(): start()

func _on_enemy_despawn():
	if alive_enemies <= 0 and enemy_budget <= 0: 
		queue_free()
		print("No active enemies and empty budget. Depsawning: ", self)
