extends CharacterBody2D

const PROJECTILE_SCENE = preload(
    "res://scenes/teleport_projectile.tscn"
)

@export var move_speed: float = 250.0
@export var jump_velocity: float = -550.0
@export var gravity: float = 1000.0

@onready var death_screen = get_tree().current_scene.get_node("GameUI/DeathScreen")

var body_size: Vector2 = Vector2(24, 36)
var active_projectile: Area2D
var is_dead: bool = false


func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	queue_redraw()



func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * move_speed

	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	if Input.is_action_just_pressed("teleport"):
		teleport_to_marker()

	if Input.is_action_just_pressed("throw_projectile"):
		throw_projectile()

	move_and_slide()

	# Choose the animation after movement.
	if not is_on_floor():
		$AnimatedSprite2D.play("jump")
	elif direction != 0:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")

	# Face the direction of movement.
	if direction != 0:
		$AnimatedSprite2D.flip_h = direction < 0


func throw_projectile() -> void:
	var aim_direction := (
		get_global_mouse_position() - global_position
	).normalized()

	if aim_direction.length_squared() < 0.001:
		return

	if is_instance_valid(active_projectile):
		active_projectile.queue_free()

	active_projectile = PROJECTILE_SCENE.instantiate()
	get_tree().current_scene.add_child(active_projectile)

	active_projectile.global_position = (
		global_position + aim_direction * 24.0
	)

	active_projectile.launch(aim_direction)


func teleport_to_marker() -> void:
	if not is_instance_valid(active_projectile):
		return

	if not active_projectile.is_stuck:
		return

	var destination = get_teleport_destination(active_projectile)

	if destination == null:
		return

	global_position = destination
	velocity = Vector2.ZERO

	active_projectile.queue_free()
	active_projectile = null


func get_teleport_destination(projectile: Area2D) -> Variant:
	var normal: Vector2 = projectile.get("hit_normal")
	var hit_body = projectile.get("hit_body") as StaticBody2D

	if hit_body == null:
		return null

	var shape_node := hit_body.get_node_or_null(
        "CollisionShape2D"
	) as CollisionShape2D

	var is_platform := hit_body.is_in_group(
        "climbable_platforms"
	)

	# Find the platform's top surface when needed.
	var top_position: Vector2

	if shape_node != null and shape_node.shape is RectangleShape2D:
		var shape := shape_node.shape as RectangleShape2D
		var center := shape_node.global_position

		var left_edge := (
			center.x - shape.size.x / 2.0
			+ body_size.x / 2.0 + 2.0
		)

		var right_edge := (
			center.x + shape.size.x / 2.0
			- body_size.x / 2.0 - 2.0
		)

		if left_edge > right_edge:
			return null

		var safe_x := clampf(
			projectile.global_position.x,
			left_edge,
			right_edge
		)

		top_position = Vector2(
			safe_x,
			center.y - shape.size.y / 2.0
			- body_size.y / 2.0 - 2.0
		)
	else:
		top_position = projectile.global_position + Vector2(
			0.0, -body_size.y / 2.0 - 2.0
		)

	var destination: Vector2

	if normal.y < -0.7:
		# Hit the top: land on it.
		destination = top_position

	elif abs(normal.x) > 0.7:
		if is_platform:
			# Hit a platform's side: climb onto its top.
			destination = top_position
		else:
			# Hit a wall: appear beside it and fall.
			destination = projectile.global_position + Vector2(
				normal.x * (body_size.x / 2.0 + 2.0),
				0.0
			)

	
	elif normal.y > 0.7:
		# Hit the underside or ceiling: appear below it and fall.
		destination = projectile.global_position + Vector2(
			0.0, body_size.y / 2.0 + 2.0
		)

	else:
		return null

	if destination_is_blocked(destination):
		return null

	return destination


func destination_is_blocked(destination: Vector2) -> bool:
	var rectangle := RectangleShape2D.new()
	rectangle.size = body_size

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = rectangle
	query.transform = Transform2D(0.0, destination)
	query.collision_mask = 1
	query.exclude = [get_rid()]

	return not get_world_2d().direct_space_state \
		.intersect_shape(query, 1).is_empty()

func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO

	if is_instance_valid(active_projectile):
		active_projectile.queue_free()
		active_projectile = null

	$AnimatedSprite2D.play("death")
	death_screen.show()
