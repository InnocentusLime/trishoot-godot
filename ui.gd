extends CanvasLayer

@onready var score: Control = $HUD/Stack/Score
@onready var score_label: Label = $HUD/Stack/Score/Label
@onready var hp: Label = $HUD/Stack/Health
@onready var comboer: Control = $HUD/Stack/Comboer
@onready var wave_start: Control = $WaveCompPort/WaveStart

@export var combo_widget: PackedScene
@export var wave_start_widget: PackedScene

var current_score = 0
var current_hp = 3
var score_distort = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	GameEvents.score_changed.connect(_on_score_changed)
	GameEvents.game_over.connect(_on_game_over)
	GameEvents.demo_over.connect(_on_demo_over)
	score_label.text = "Score: %d" % current_score
	
func _on_demo_over():
	get_tree().create_tween()\
		.tween_property($DemoOver, "modulate", Color.WHITE, 3.0)
	
func _on_game_over():
	$HUD.visible = false

func _on_wave_complete():
	var sign: WaveStart = wave_start_widget.instantiate()
	wave_start.add_child(sign)

func _on_player_hp_change(new_hp: int):
	current_hp = new_hp
	hp.text = "HP: %d" % current_hp

func _on_score_changed(score_delta: int, score_label: String):
	var combo: ComboShower = combo_widget.instantiate()
	combo.end = score.global_position
	combo.score_delta = score_delta
	combo.score_label = score_label
	combo.reward_appeared.connect(_on_reward_shown)
	comboer.add_child(combo)

func _on_reward_shown(score_delta):
	current_score += score_delta
	score_distort = 1.0
	score_label.text = "Score: %d" % current_score

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var k = 1.0 + elastic(score_distort)
	score_label.scale = Vector2(k, k)
	score_distort = max(0.0, score_distort - delta*4.0)
	
func elastic(x: float) -> float:
	return 256.0/27.0 * x * pow(1 - x, 3.0)
