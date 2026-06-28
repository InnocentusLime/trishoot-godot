# Timer properties:
# Autostart: false
# Oneshot: false
class_name Spawner extends Timer

enum SpawnPoint {TEST=-1}

const CENTER_X: float = 450

@export var spawn_point: SpawnPoint = SpawnPoint.TEST
@export var to_spawn: PackedScene
@export var enemy_budget: int = 1
@export var enemy_cap: int = 1


var spawn_pos: Vector2
var alive_enemies: int

func _enter_tree(): start()

func _on_spawn():
	var enemy: Enemy = to_spawn.instantiate()
	enemy.position = spawn_pos
	enemy.jumps_on_left = spawn_pos.x < CENTER_X
	enemy.killed.connect(_on_enemy_die)
	add_child(enemy)
	alive_enemies += 1
	enemy_budget -= 1
	
	if enemy_budget <= 0 or alive_enemies >= enemy_cap: 
		stop()
	
func _on_enemy_die():
	alive_enemies -= 1
	if enemy_budget > 0 and is_stopped(): start()

func _on_enemy_despawn(enemy: Node):
	# No children, no budget. Kill ourselves
	if alive_enemies <= 0 and enemy_budget <= 0: 
		queue_free()
		print("No active enemies and empty budget. Depsawning: ", self)
