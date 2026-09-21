class_name Rocket
extends Area2D

const BOOST_PERCENTAGE: float = 3.25
const PARRIED_SPEED: float = 400.0

@export var assist_angle: float
@export var rot_speed: float
@export var move_vel: float
@export var move_dir: Vector2
@export var explosion: PackedScene
@export var level_to_parry: int

@onready var speed_timer: Timer = $SpeedTimer

var parried: bool = false

func _on_dmg(dmg_pos: Vector2, level: int) -> bool:
	if parried or not speed_timer.is_stopped(): return false
	if level < level_to_parry: return false
	move_vel = PARRIED_SPEED
	parried = true
	
	move_dir = (position - GameEvents.player_pos).normalized()
	var rocketers := get_tree().get_nodes_in_group("rocketers")
	if rocketers.is_empty(): return true
	
	var closest_reachable_rocketer_dist := INF
	var closest_reachable_rocketer_dir := Vector2.ZERO
	for rocketer in rocketers:
		var rocketer_node: Node2D = rocketer
		var dr_to_rocketer := rocketer_node.position - position
		var reorient_angle := move_dir.angle_to(dr_to_rocketer)
		if dr_to_rocketer.length() < closest_reachable_rocketer_dist and reorient_angle <= deg_to_rad(assist_angle):
			closest_reachable_rocketer_dir = dr_to_rocketer.normalized()
			closest_reachable_rocketer_dist = dr_to_rocketer.length()
	if closest_reachable_rocketer_dist < INF:
		move_dir = closest_reachable_rocketer_dir
	
	return true

func _physics_process(delta: float):
	var k := speed_timer.time_left/speed_timer.wait_time
	var player_dir := (GameEvents.player_pos - position).normalized()
	if not parried:
		var angle_to_player := move_dir.angle_to(player_dir)
		var rot_delta := deg_to_rad(rot_speed)*pow((1-k), 2.0)*delta
		var act_rot_abs := minf(absf(angle_to_player), rot_delta)
		var act_rot := signf(angle_to_player)*act_rot_abs
		move_dir = move_dir.rotated(act_rot)
	
	var vel := move_vel + (move_vel * BOOST_PERCENTAGE) * k
	position += move_dir*vel*delta
	rotation = move_dir.angle()
	
	for node in get_overlapping_bodies():
		if node is Enemy and parried:
			node._on_dmg(position, 999)
			explode(false)

func _on_collision(player_hurtbox: Area2D):
	var parent := player_hurtbox.get_parent()
	if parent == null: return
	if parent is Player:
		parent._on_dmg(position, true, true)
		explode(false)
		
func explode(quiet: bool = true):
	var the_explosion: Explosion = explosion.instantiate()
	the_explosion.position = position
	the_explosion.quiet = quiet
	add_sibling(the_explosion)
	queue_free()
