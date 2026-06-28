extends Node

@export var spawn_points: Dictionary[Spawner.SpawnPoint, Marker2D]
@export var waves: Array[PackedScene]

var current_wave: int = 0

func _ready():
	start_wave()

func start_wave():
	if current_wave >= waves.size():
		print("no more waves!")
		queue_free()
		return
	
	var wave_scene := waves[current_wave]
	var wave: Wave = wave_scene.instantiate()
	wave.spawn_points = spawn_points
	add_child(wave)
	current_wave += 1

func _on_wave_done(wave: Node):
	# The engine is busy killing my child. Please call later
	start_wave.call_deferred()
