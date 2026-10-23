
extends StaticBody2D

@export var platform_size: Vector2 = Vector2(220, 24)
@export var platform_color: Color = Color(0.251, 0.302, 1.0, 1.0)


func _draw() -> void:
	draw_rect(
		Rect2(-platform_size / 2.0, platform_size),
		platform_color
	)
