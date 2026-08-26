class_name Wave extends Timer

const BONUS_OFFSET_RANGE: int = 3
const BONUS_OFFSET_INCREMENT: float = 7.0

@onready var upgrade: PackedScene = preload("res://gun_upgrade.tscn")
@onready var bonus: PackedScene = preload("res://score_bonus.tscn")

@export var upgrades_per_spawner: int = 3
@export var total_upgrades_limit: int = 6
@export var ticks_to_spawn_upgrade: int =  3

@export var bonuses_per_spawner: int = 3
@export var total_bonuses_limit: int = 6
@export var ticks_to_spawn_score_bonus: int =  5


var spawn_points: Dictionary[Spawner.SpawnPoint, Marker2D]
var item_spawn_points: Array[Marker2D]
var tick: int = 0

func _item_spawn_tick():
	tick += 1
	if tick % ticks_to_spawn_upgrade == 0: spawn_upgrade()
	if tick % ticks_to_spawn_score_bonus == 0: spawn_score_bonus()

func spawn_score_bonus():
	var total_bonuses := 0
	for spawnpoint in item_spawn_points:
		for child in spawnpoint.get_children():
			if child is GunUpgrade: total_bonuses += 1
	if total_bonuses >= total_bonuses_limit: return
	
	for _idx in range(10):
		var spawnpoint_idx := randi_range(0, len(item_spawn_points)-1)
		var spawnpoint := item_spawn_points[spawnpoint_idx]
		if spawnpoint.get_child_count() >= bonuses_per_spawner:
			continue
		
		var bonus_obj: ScoreBonus = bonus.instantiate()
		var position := Vector2.ZERO
		position.x = randi_range(-BONUS_OFFSET_RANGE, BONUS_OFFSET_RANGE) * BONUS_OFFSET_INCREMENT
		position.y = randi_range(-BONUS_OFFSET_RANGE, BONUS_OFFSET_RANGE) * BONUS_OFFSET_INCREMENT
		bonus_obj.position = position
		spawnpoint.add_child(bonus_obj)
		break

func spawn_upgrade():
	var total_bonuses := 0
	for spawnpoint in item_spawn_points:
		for child in spawnpoint.get_children():
			if child is GunUpgrade: total_bonuses += 1
	if total_bonuses >= total_upgrades_limit: return
	
	for _idx in range(10):
		var spawnpoint_idx := randi_range(0, len(item_spawn_points)-1)
		var spawnpoint := item_spawn_points[spawnpoint_idx]
		if spawnpoint.get_child_count() >= upgrades_per_spawner:
			continue
		
		var upgrade_obj: GunUpgrade = upgrade.instantiate()
		var position := Vector2.ZERO
		position.x = randi_range(-BONUS_OFFSET_RANGE, BONUS_OFFSET_RANGE) * BONUS_OFFSET_INCREMENT
		position.y = randi_range(-BONUS_OFFSET_RANGE, BONUS_OFFSET_RANGE) * BONUS_OFFSET_INCREMENT
		upgrade_obj.position = position
		spawnpoint.add_child(upgrade_obj)
		break

func _enter_tree():
	for child in get_children():
		var spawner := child as Spawner
		var spawn_point := spawner.spawn_point
		assert(spawn_points.has(spawn_point), "no spawn point: %d" % spawn_point)
		spawner.spawn_pos = spawn_points[spawn_point].position

func _on_spawner_dying(spawner: Node):
	if get_child_count() > 1: return
	print("All spawners terminated. Wave finished: ", self)
	queue_free()
