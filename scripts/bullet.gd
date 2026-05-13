extends Area2D


var speed = 80.0
var damage = 20
var instant_kill = false

func _ready() -> void:
	
	await  get_tree().create_timer(3.0).timeout
	queue_free()
	
	pass

func _physics_process(delta: float) -> void:
	
	position += transform.x * speed * delta
	
	pass
