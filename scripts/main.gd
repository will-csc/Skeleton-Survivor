extends Node2D

@onready var enemy_spawner = $EnemySpawner

var game_started = false
var game_over = false

func _process(delta):
	
	# Atire para começar
	if not game_started:
		if Input.is_action_just_pressed("shoot"):
			start_game()
			return
	
	# R para reiniciar
	if game_over:
		if Input.is_action_just_pressed("restart"):
			get_tree().reload_current_scene()

func start_game():
	game_started = true
	enemy_spawner.game_started = true
	
	for i in range(enemy_spawner.initial_spawn_count):
		enemy_spawner._try_spawn_enemy()

func show_game_over():
	game_over = true
