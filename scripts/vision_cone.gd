extends Node2D

@export var view_range: float = 300.0
@export var view_angle: float = 60.0   # total width in degrees

const RAY_COUNT := 24

# Cone outline in this node's local space, cut short by walls and platforms.
var cone_points := PackedVector2Array()


func _physics_process(_delta: float) -> void:
	update_cone_points()
	queue_redraw()
	check_for_player()


func update_cone_points() -> void:
	var space := get_world_2d().direct_space_state
	var half_angle := deg_to_rad(view_angle / 2.0)

	var points := PackedVector2Array()
	points.append(Vector2.ZERO)

	for i in range(RAY_COUNT + 1):
		var t := float(i) / RAY_COUNT
		var angle := -half_angle + (2.0 * half_angle) * t

		# Where this ray would end if nothing blocked it.
		var local_end := Vector2.RIGHT.rotated(angle) * view_range

		var query := PhysicsRayQueryParameters2D.create(
			global_position,
			to_global(local_end),
			1   # layer 1 = ground and platforms only
		)
		var hit := space.intersect_ray(query)

		if hit.is_empty():
			points.append(local_end)
		else:
			# Stop the cone at the wall or platform.
			points.append(to_local(hit["position"]))

	cone_points = points


func _draw() -> void:
	if cone_points.size() < 3:
		return

	draw_colored_polygon(cone_points, Color(1, 0, 0, 0.18))

	var outline := cone_points.duplicate()
	outline.append(Vector2.ZERO)
	draw_polyline(outline, Color(1, 0, 0, 0.7), 2.0)


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
