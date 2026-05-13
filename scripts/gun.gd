extends Node2D

@onready var sprite = $Sprite2D
@onready var bullet_marker = $Sprite2D/Bullet_Marker

@onready var player = get_tree().get_first_node_in_group("Player")

@export var bullet_scene: PackedScene
@export var projectiles_per_shot = 1
@export var spread_angle_degrees = 0.0
@export var randomize_spread = false
@export var full_circle_spread = false
@export var instant_kill = false

enum State {GROUND , HAND}
var actual_state = State.GROUND

@export_category("Gun States")
@export var fire_time = 0.5
@export var bullet_speed = 200.0
@export var damage = 10.0
@export var bullet_size = 1.0

var can_shoot = true
var drop_token = 0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	pass
	

func _process(delta: float) -> void:
	
	if player.is_alive and actual_state == State.HAND:
		aim()
		shoot()
	pass

func aim():
	
	look_at(get_global_mouse_position())
	
	if get_global_mouse_position().x < global_position.x:
		sprite.scale.y = -1
	else:
		sprite.scale.y = 1
	
	pass
	
func shoot ():
	
	if Input.is_action_just_pressed("shoot") and bullet_scene and can_shoot:
		
		can_shoot = false
		$Timer.start(fire_time)
		for projectile_index in range(projectiles_per_shot):
			spawn_bullet(projectile_index)
	
	pass

func spawn_bullet(projectile_index: int) -> void:
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	
	bullet.global_position = bullet_marker.global_position
	bullet.global_rotation = global_rotation + get_spread_offset(projectile_index)
	bullet.speed = bullet_speed
	bullet.damage = damage
	bullet.instant_kill = instant_kill
	bullet.scale = Vector2.ONE * bullet_size

func get_spread_offset(projectile_index: int) -> float:
	if projectiles_per_shot <= 1:
		return 0.0
	
	if full_circle_spread:
		return rng.randf_range(-PI, PI)
	
	if spread_angle_degrees <= 0.0:
		return 0.0
	
	var half_spread_radians = deg_to_rad(spread_angle_degrees * 0.5)
	if randomize_spread:
		return rng.randf_range(-half_spread_radians, half_spread_radians)
	
	var step_ratio = float(projectile_index) / float(projectiles_per_shot - 1)
	return lerp(-half_spread_radians, half_spread_radians, step_ratio)

func grab():
	var hand = player.get_node("Hand")
	var target_position = Vector2.ZERO
	
	if hand.get_child_count() > 0:
		target_position = hand.get_child(0).position
		hand.get_child(0).queue_free()
	
	actual_state = State.HAND
	drop_token += 1
	$Area2D.queue_free()
	call_deferred("_finish_grab", hand, target_position)
	
	pass

func _finish_grab(hand: Node, target_position: Vector2) -> void:
	reparent(hand, true)
	position = target_position

func prepare_drop(duration: float = 5.0) -> void:
	drop_token += 1
	var current_drop_token = drop_token
	await get_tree().create_timer(duration).timeout
	
	if current_drop_token != drop_token:
		return
	
	if actual_state != State.GROUND:
		return
	
	queue_free()

func _on_area_2d_area_entered(area: Area2D) -> void:
	
	if area.get_parent().is_in_group("Player"):
		grab()
	
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	
	can_shoot = true
	
	pass
