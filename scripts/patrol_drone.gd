extends CharacterBody2D

@export var patrol_distance: float = 200.0
@export var patrol_speed: float = 100.0
@export var view_range: float = 200.0
@export var cone_width: float = 100.0

var start_x: float
var direction: float = 1.0

@onready var ray: RayCast2D = $VisionCone/RayCast2D


func _ready() -> void:
	start_x = global_position.x
	$AnimatedSprite2D.play("drone_run")
	ray.enabled = true
	queue_redraw()


func _physics_process(_delta: float) -> void:
	velocity.x = direction * patrol_speed
	move_and_slide()

	if global_position.x >= start_x + patrol_distance:
		direction = -1.0
	elif global_position.x <= start_x - patrol_distance:
		direction = 1.0

	# Flip the sprite to face the direction of movement.
	$AnimatedSprite2D.flip_h = direction > 0

	check_for_player()
	queue_redraw()




func _draw() -> void:
	var points := PackedVector2Array([
		Vector2.ZERO,
		Vector2(-cone_width / 2.0, view_range),
		Vector2(cone_width / 2.0, view_range)
	])

	draw_colored_polygon(points, Color(1, 0, 0, 0.18))
	points.append(Vector2.ZERO)
	draw_polyline(points, Color(1, 0, 0, 0.7), 2.0)


func check_for_player() -> void:
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return

	var player = players[0]
	var to_player: Vector2 = player.global_position - global_position

	if to_player.y < 0 or to_player.y > view_range:
		return

	var allowed_width: float = (cone_width / 2.0) * (to_player.y / view_range)
	if abs(to_player.x) > allowed_width:
		return

	ray.global_position = $VisionCone.global_position
	ray.target_position = ray.to_local(player.global_position)
	ray.force_raycast_update()

	if ray.is_colliding() and ray.get_collider() == player:
		player.die()
