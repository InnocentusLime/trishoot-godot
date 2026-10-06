extends Node

@export var item_spawn_points: Array[Marker2D]
@export var spawn_points: Dictionary[Spawner.SpawnPoint, Marker2D]
@export var waves: Array[PackedScene]

var mines: Node2D

var current_wave: int = 0

func start_wave():
	if mines != null:
		mines.queue_free()
		mines = null
	
	if current_wave >= waves.size():
		print("no more waves!")
		queue_free()
		return
	
	var wave_scene := waves[current_wave]
	var wave: Wave = wave_scene.instantiate()
	wave.spawn_points = spawn_points
	wave.item_spawn_points = item_spawn_points
	add_child(wave)
	current_wave += 1
	
	wave.mines.reparent(self)
	mines = wave.mines

func _on_wave_done(child: Node):
	if not child is Wave: return
	print("wave done")
	# The engine is busy killing my child. Please call later
	start_wave.call_deferred()
