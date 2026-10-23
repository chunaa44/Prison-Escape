extends CharacterBody2D

@export var patrol_distance: float = 200.0
@export var patrol_speed: float = 100.0

var start_x: float
var direction: float = 1.0


func _ready() -> void:
	start_x = global_position.x
	$AnimatedSprite2D.play("drone_run")


func _physics_process(_delta: float) -> void:
	velocity.x = direction * patrol_speed
	move_and_slide()

	if global_position.x >= start_x + patrol_distance:
		direction = -1.0
	elif global_position.x <= start_x - patrol_distance:
		direction = 1.0

	$AnimatedSprite2D.flip_h = direction > 0
