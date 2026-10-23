extends Node2D

@export var view_range: float = 300.0
@export var view_angle: float = 60.0   # total width in degrees


func _process(_delta: float) -> void:
	queue_redraw()
	check_for_player()


func _draw() -> void:
	var half_angle := deg_to_rad(view_angle / 2.0)
	var points := PackedVector2Array([Vector2.ZERO])

	for i in range(25):
		var angle := -half_angle + (2.0 * half_angle) * i / 24.0
		points.append(Vector2.RIGHT.rotated(angle) * view_range)

	draw_colored_polygon(points, Color(1, 0, 0, 0.18))
	points.append(Vector2.ZERO)
	draw_polyline(points, Color(1, 0, 0, 0.7), 2.0)


func check_for_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return

	# 1. Is the player close enough?
	var to_player: Vector2 = player.global_position - global_position
	if to_player.length() > view_range:
		return

	# 2. Is the player inside the cone angle?
	var facing := Vector2.RIGHT.rotated(global_rotation)
	if absf(facing.angle_to(to_player)) > deg_to_rad(view_angle / 2.0):
		return

	# 3. Is a wall or platform in the way?
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position,
		1   # layer 1 = ground and platforms only
	)
	var blocked := not get_world_2d().direct_space_state.intersect_ray(query).is_empty()

	if not blocked:
		player.die()
