extends Area2D

const FLY_DIST: float = -765.0

@export var explosion: PackedScene

@onready var collider: CollisionShape2D = $Collider
@onready var sprite: Sprite2D = $Sprite
@onready var warning: Sprite2D = $Warning
@onready var arm_timer: Timer = $ArmTimer
@onready var land: AudioStreamPlayer2D = $Land

func _ready():
	arm_timer.start((position.x / 64.0) * 0.3 + (position.y / 64.0) * 0.2)

func _process(delta: float):
	var k := arm_timer.time_left / 0.3
	sprite.position.y = FLY_DIST * ease(k, 1.0)

func _on_arm():
	collider.set_deferred("disabled", false)
	warning.visible = false
	land.play()

func _on_overlap(victim: Node2D):
	if not victim is Player: return
	var the_explosion: Node2D = explosion.instantiate()
	the_explosion.position = position
	add_sibling(the_explosion)
	if victim is Player:
		# NOTE: we call _on_dmg directly, because we are detecting
		#       the object itself, no the hurtbox
		victim._on_dmg(position, true, true)
	queue_free()
