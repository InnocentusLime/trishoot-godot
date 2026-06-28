class_name Wave extends Node

var spawn_points: Dictionary[Spawner.SpawnPoint, Marker2D]

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
