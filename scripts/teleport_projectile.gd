extends Area2D

@export var throw_speed: float = 900.0

var direction: Vector2 = Vector2.RIGHT
var is_stuck: bool = false
var hit_normal: Vector2 = Vector2.ZERO
var hit_body: StaticBody2D


func launch(throw_direction: Vector2) -> void:
	direction = throw_direction.normalized()


func _physics_process(delta: float) -> void:
	if is_stuck:
		return

	var next_position := global_position + direction * throw_speed * delta

	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		next_position,
		1
	)

	var result := get_world_2d().direct_space_state.intersect_ray(query)

	if not result.is_empty():
		var body := result["collider"] as StaticBody2D

		if body != null:
			global_position = result["position"]
			hit_normal = result["normal"]
			hit_body = body
			is_stuck = true
			set_deferred("monitoring", false)
			queue_redraw()
			return

	global_position = next_position


func _draw() -> void:
	draw_circle(Vector2.ZERO, 8.0, Color(0.2, 1.0, 0.8))
	draw_circle(Vector2.ZERO, 3.0, Color.WHITE)
