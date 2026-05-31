class_name Think
extends CharacterBody2D

@onready var ai_base: AIBase = $AIBase
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready():
	anim.current_animation = "idle"

func _on_dmg(attack_pos: Vector2): 
	if !ai_base._on_dmg(attack_pos): return
	anim.current_animation = "hurt"

func _jump():
	anim.current_animation = "jump"
