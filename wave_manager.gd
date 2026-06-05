extends Node2D

@onready var spawn_timer: Timer = $SpawnTimer
@onready var left_spawn: Node2D = $LeftSpawnPoint
@onready var right_spawn: Node2D = $RightSpawnPoint

const SPAWN_STEP: float = 32.0

@export var enemies: Array[PackedScene]

# Wave cfg
var spawn_time: float = 0.7
var probabilities: Array[float] = [0.5, 1.5]
var enemmy_group_prob: float = 0.7
var lookup: Array[int] = [0, 1]
var enemy_limit: int = 10
var enemies_spawn_left: int = 10

var weights: Array[float]
var max_weight: float

var enemies_spawned: int = 0
var enemies_killed: int = 0
var enemies_despawn_left: int = 0

var wave_num: int = -1
var locked: bool = false

func start_wave():
	wave_num += 1
	
	if wave_num >= 9: return
	
	match wave_num % 3:
		0: 
			enemies_spawn_left = 10
			enemy_limit = 5
			enemmy_group_prob = 0.4
			spawn_time = 0.7
		1: 
			enemies_spawn_left = 20
			enemy_limit = 10
			enemmy_group_prob = 0.6
			spawn_time = 0.5
		2: 
			enemies_spawn_left = 40
			enemy_limit = 15
			enemmy_group_prob = 0.7
			spawn_time = 0.4
			
	match wave_num / 3:
		0:
			lookup = [0, 1]
			probabilities = [0.6, 1.5]
		1:
			lookup = [0, 1, 2]
			probabilities = [0.6, 0.4, 0.4]
		2:
			lookup = [0, 1, 2, 3]
			probabilities = [0.6, 0.8, 0.4, 0.2]
	
	enemies_spawned = 0
	enemies_killed = 0
	enemies_despawn_left = enemies_spawn_left
	
	spawn_timer.start(spawn_time)
	max_weight = 0.0
	weights.clear()
	for idx in range(lookup.size()):
		max_weight += probabilities[idx]
		weights.append(max_weight)

func _ready(): 
	GameEvents.enemy_died.connect(_on_enemy_dead)
	GameEvents.wave_start.connect(start_wave)
	GameEvents.enemy_despawned.connect(_on_enemy_despawned)
	GameEvents.game_start.connect(start_wave)
	GameEvents.game_over.connect(_on_game_over)
	
func _on_enemy_dead():
	enemies_killed += 1
	enemies_spawned -= 1
	spawn_enemies()
	
func _on_enemy_despawned():
	enemies_despawn_left -= 1
	if enemies_despawn_left <= 0:
		GameEvents.wave_complete.emit()
		GameEvents.wave_start.emit()

func _on_do_spawn():
	spawn_enemies()
	
func spawn_enemies():
	var succ = spawn_enemy()
	while succ:
		if randf() < enemmy_group_prob: break
		succ = spawn_enemy()

func spawn_enemy() -> bool:
	if locked: return false
	if enemies_spawn_left <= 0: return false
	
	var spawn_pos = pick_spawnpoint()
	var to_spawn: PackedScene = pick_enemy()
	if to_spawn == null: return false
	var enemy: Node2D = to_spawn.instantiate()
	enemy.position = spawn_pos
	add_sibling(enemy)
	
	enemies_spawned += 1
	enemies_spawn_left -= 1
	if enemies_spawned < enemy_limit:
		spawn_timer.start()
	return true

func pick_spawnpoint() -> Vector2:
	var spawn_point: Node2D
	
	if GameEvents.player_pos.x > 550:
		spawn_point = left_spawn
	elif GameEvents.player_pos.x < 400:
		spawn_point = right_spawn
	else:
		if randi_range(0, 1) == 0: spawn_point = left_spawn
		else: spawn_point = right_spawn
	
	var spawn_pos: Vector2 = spawn_point.global_position
	spawn_pos.y += SPAWN_STEP * randi_range(-3, 3)
	return spawn_pos

func pick_enemy() -> PackedScene:
	var weight = randf_range(0.0, max_weight)
	for idx in range(weights.size()):
		if weight <= weights[idx]:
			return enemies[lookup[idx]]
	return null
	
func _on_game_over():
	locked = true
