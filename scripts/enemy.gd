extends Area2D

const PISTOL_SCENE = preload("res://prefabs/pistol.tscn")
const AIRBOW_SCENE = preload("res://prefabs/airbow.tscn")
const MINIGUN_SCENE = preload("res://prefabs/minigun.tscn")
const SHOTGUN_SCENE = preload("res://prefabs/shotgun.tscn")
const SNIPER_SCENE = preload("res://prefabs/sniper.tscn")
const LEGENDARY_MINIGUN_SCENE = preload("res://prefabs/legendary_minigun.tscn")
const DEFAULT_DROP_SCENES = [PISTOL_SCENE, AIRBOW_SCENE, MINIGUN_SCENE, SHOTGUN_SCENE, SNIPER_SCENE]
const KILLS_META_KEY = "enemy_kills"
const DROP_CHANCE_BONUS_PER_10_KILLS = 0.01
const MAX_DROP_CHANCE = 0.20
const LEGENDARY_BASE_CHANCE = 0.001
const LEGENDARY_CHANCE_PER_10_KILLS = 0.005
const MAX_LEGENDARY_CHANCE = 0.10
const SPEED_BONUS_PER_20_KILLS = 10.0
const MAX_SPEED = 25

@onready var sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

var speed = 15
var velocity = Vector2.ZERO
@export var knockback_force = 80.0
@export var shots_to_die = 3
@export_range(0.0, 1.0, 0.01) var drop_chance = 0.05
@export var drop_scenes: Array[PackedScene] = []
@export var face_deadzone_x = 6.0
var hits_taken = 0
var is_alive = true
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	if drop_scenes.is_empty():
		for scene in DEFAULT_DROP_SCENES:
			drop_scenes.append(scene)

func _physics_process(delta: float) -> void:
	
	if is_alive:
		move(delta)
	pass
	
func move(delta):
	
	var player = get_tree().get_first_node_in_group("Player")
	if not player: return
	
	var direction = global_position.direction_to(player.global_position)
	
	var push = Vector2.ZERO
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy != self:
			if global_position.distance_to(enemy.global_position) < 40:
				push += enemy.global_position.direction_to(global_position)
				
	var final_direction = (direction + push).normalized()
	
	velocity = velocity.lerp(final_direction * get_scaled_speed(), 0.1)
	
	global_position += velocity * delta
	
	var x_distance_to_player = player.global_position.x - global_position.x
	if x_distance_to_player > face_deadzone_x:
		sprite.flip_h = false
	elif x_distance_to_player < -face_deadzone_x:
		sprite.flip_h = true
	
	pass


func _on_area_entered(area: Area2D) -> void:
	if not is_alive:
		return
	
	if area.is_in_group("bullets"):
		area.queue_free()
		if bool(area.get("instant_kill")):
			animation_player.play("hit")
			die()
			return
			
		var knockback_direction = area.global_position.direction_to(global_position)
		velocity += knockback_direction * knockback_force
		
		hits_taken += 1
		animation_player.play("hit")
		if hits_taken >= shots_to_die:
			die()
		return
			
	var area_parent = area.get_parent()
	if area_parent != null and area_parent.is_in_group("Player"):
		area_parent.die()
		die()
	
	pass # Replace with function body.
	
	
func die ():
	if not is_alive:
		return
	
	is_alive = false
	monitoring = false
	$CollisionShape2D.queue_free()
	drop_loot()
	register_kill()
	sprite.play("death")
	await get_tree().create_timer(1.0).timeout
	queue_free()
	
	pass

func drop_loot() -> void:
	if rng.randf() <= get_legendary_drop_chance():
		spawn_loot(LEGENDARY_MINIGUN_SCENE)
		return
	
	var available_drop_scenes = get_available_drop_scenes()
	if available_drop_scenes.is_empty():
		return
	
	if rng.randf() > get_scaled_drop_chance():
		return
	
	var loot_scene = available_drop_scenes[rng.randi_range(0, available_drop_scenes.size() - 1)]
	if loot_scene == null:
		return
	
	spawn_loot(loot_scene)

func spawn_loot(loot_scene: PackedScene) -> void:
	var loot = loot_scene.instantiate()
	get_tree().current_scene.add_child(loot)
	loot.global_position = global_position
	if loot.has_method("prepare_drop"):
		loot.prepare_drop(5.0)

func get_available_drop_scenes() -> Array[PackedScene]:
	var available_drop_scenes: Array[PackedScene] = []
	
	for scene in drop_scenes:
		if scene == null:
			continue
		if scene.resource_path == LEGENDARY_MINIGUN_SCENE.resource_path:
			continue
		available_drop_scenes.append(scene)
	
	return available_drop_scenes

func get_scaled_drop_chance() -> float:
	var kills = get_kills_count()
	var bonus_steps = int(kills / 10.0)
	return min(drop_chance + (bonus_steps * DROP_CHANCE_BONUS_PER_10_KILLS), MAX_DROP_CHANCE)

func get_scaled_speed() -> float:
	var kills = get_kills_count()
	var bonus_steps = int(kills / 20.0)
	return min(speed + (bonus_steps * SPEED_BONUS_PER_20_KILLS),MAX_SPEED)

func get_legendary_drop_chance() -> float:
	var kills = get_kills_count()
	var bonus_steps = int(kills / 10.0)
	return min(LEGENDARY_BASE_CHANCE + (bonus_steps * LEGENDARY_CHANCE_PER_10_KILLS), MAX_LEGENDARY_CHANCE)

func get_kills_count() -> int:
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return 0
	
	return int(current_scene.get_meta(KILLS_META_KEY, 0))

func register_kill() -> void:
	var current_scene = get_tree().current_scene
	if current_scene == null:
		return
	
	current_scene.set_meta(KILLS_META_KEY, get_kills_count() + 1)
