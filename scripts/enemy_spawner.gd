extends Node2D

const KILLS_META_KEY = "enemy_kills"
const KILLS_PER_WAVE_STEP = 20
const ENEMIES_PER_WAVE_STEP = 5

@export var enemy_scene: PackedScene
@export var spawn_interval = 2.5
@export var max_enemies = 8
@export var initial_spawn_count = 2
@export var min_spawn_distance = 140.0
@export var max_spawn_distance = 220.0

var game_started = false
var rng := RandomNumberGenerator.new()
var spawn_timer: Timer
var last_spawn_bonus_steps = 0

func _ready() -> void:
	rng.randomize()
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_try_spawn_enemy)
	add_child(spawn_timer)
	spawn_timer.start()
	
	# for _i in range(initial_spawn_count):
	# 	_try_spawn_enemy()

func _process(_delta: float) -> void:
	
	if not game_started:
		return
	
	var current_bonus_steps = get_spawn_bonus_steps()
	if current_bonus_steps <= last_spawn_bonus_steps:
		return
	
	var extra_spawn_count = (current_bonus_steps - last_spawn_bonus_steps) * ENEMIES_PER_WAVE_STEP
	last_spawn_bonus_steps = current_bonus_steps
	
	for _i in range(extra_spawn_count):
		_try_spawn_enemy()

func _try_spawn_enemy() -> void:
	

	if not game_started:
		return
	
	if enemy_scene == null:
		return
	
	if get_tree().get_nodes_in_group("enemies").size() >= get_scaled_max_enemies():
		return
	
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return
	
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = _get_spawn_position()

func _get_spawn_position() -> Vector2:
	var viewport_size = get_viewport_rect().size
	var spawn_margin = max(min_spawn_distance, 24.0)
	var edge = rng.randi_range(0, 3)
	
	match edge:
		0:
			return Vector2(rng.randf_range(0.0, viewport_size.x), -spawn_margin)
		1:
			return Vector2(viewport_size.x + spawn_margin, rng.randf_range(0.0, viewport_size.y))
		2:
			return Vector2(rng.randf_range(0.0, viewport_size.x), viewport_size.y + spawn_margin)
		_:
			return Vector2(-spawn_margin, rng.randf_range(0.0, viewport_size.y))

func get_scaled_max_enemies() -> int:
	return max_enemies + (get_spawn_bonus_steps() * ENEMIES_PER_WAVE_STEP)

func get_spawn_bonus_steps() -> int:
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return 0
	
	return int(int(current_scene.get_meta(KILLS_META_KEY, 0)) / float(KILLS_PER_WAVE_STEP))
