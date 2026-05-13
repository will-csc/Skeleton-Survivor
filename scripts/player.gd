extends CharacterBody2D


@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D



@export var speed = 55.0

var direction = Vector2.ZERO

var is_alive = true

func _physics_process(delta:float) -> void:
	
	if is_alive:
		move()
		anim()

	pass
	
func move():
	
	direction = Input.get_vector("left","right","up", "down")

	if direction != Vector2.ZERO:
		velocity = direction * speed
		
	else: velocity = velocity.move_toward(Vector2.ZERO , speed )

	move_and_slide()
	keep_on_screen()

pass


func keep_on_screen() -> void:
	var viewport_size = get_viewport_rect().size
	var half_size = Vector2.ZERO
	var shape = collision_shape.shape

	if shape is CapsuleShape2D:
		half_size = Vector2(shape.radius, shape.radius + (shape.height * 0.5))
	elif shape is RectangleShape2D:
		half_size = shape.size * 0.5

	global_position.x = clamp(global_position.x, half_size.x, viewport_size.x - half_size.x)
	global_position.y = clamp(global_position.y, half_size.y, viewport_size.y - half_size.y)


func anim():
	
	if direction == Vector2.ZERO:
		anim_sprite.play("idle")
	else:
		if abs(direction.x) > abs(direction.y):
			anim_sprite.play("walk_side")
			if direction.x < 0:
				anim_sprite.flip_h = true
			else:
				anim_sprite.flip_h = false
		elif  direction.y > 0:
			anim_sprite.play("walk_down")
		else:
			anim_sprite.play("walk_up")
	
	
	pass
	
func die():
	
	is_alive = false
	anim_sprite.play("death")
	$Area2D.queue_free()
	await  get_tree().create_timer(3.0).timeout
	get_tree().reload_current_scene()
	
	pass
