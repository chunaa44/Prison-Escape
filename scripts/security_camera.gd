extends Node2D

@export var view_range: float = 350.0
@export var view_angle: float = 60.0
@export var scan_speed: float = 30.0

var scan_direction: float = 1.0
var start_rotation: float = 0.0

@onready var vision_cone: Node2D = $VisionCone
@onready var ray: RayCast2D = $VisionCone/RayCast2D

func _ready() -> void:
	start_rotation = vision_cone.rotation
	ray.enabled = true
	$AnimatedSprite2D.play("drone_idle")

func _process(delta: float) -> void:
	vision_cone.rotation += deg_to_rad(scan_speed) * scan_direction * delta

	var offset := vision_cone.rotation - start_rotation

	if offset > deg_to_rad(35.0):
		scan_direction = -1.0
	elif offset < deg_to_rad(-35.0):
		scan_direction = 1.0

	queue_redraw()
	check_for_player()


func _draw() -> void:
	var half_angle := deg_to_rad(view_angle / 2.0)
	var points := PackedVector2Array()
	points.append(Vector2.ZERO)

	for i in range(25):
		var angle := -half_angle + (2.0 * half_angle) * i / 24.0
		points.append(Vector2.RIGHT.rotated(angle) * view_range)

	var cone_transform := vision_cone.transform

	draw_set_transform(
		cone_transform.origin,
		cone_transform.get_rotation(),
		cone_transform.get_scale()
	)

	draw_colored_polygon(
		points,
		Color(1.0, 0.0, 0.0, 0.18)
	)

	points.append(Vector2.ZERO)

	draw_polyline(
		points,
		Color(1.0, 0.0, 0.0, 0.7),
		2.0
	)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func check_for_player() -> void:
	var player := get_tree().get_first_node_in_group("player")

	if player == null:
		return

	var to_player: Vector2 = player.global_position - vision_cone.global_position
	var distance := to_player.length()

	if distance > view_range:
		return

	var angle := absf(
		wrapf(
			to_player.angle() - vision_cone.global_rotation,
			-PI,
			PI
		)
	)

	if angle > deg_to_rad(view_angle / 2.0):
		return

	ray.target_position = ray.to_local(player.global_position)
	ray.force_raycast_update()

	if ray.is_colliding() and ray.get_collider() == player:
		player.die()
