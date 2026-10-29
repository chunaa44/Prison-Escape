extends Area2D

@export var door_color: Color = Color(0.2, 1.0, 0.4, 1.0)

@onready var win_screen = get_tree().current_scene.get_node("GameUI/WinScreen")
@onready var shape_node: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	z_index = 5   # draw on top of ground and platforms
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _draw() -> void:
	# Draw exactly where the collision shape is, so they always match.
	var size: Vector2 = shape_node.shape.size
	draw_rect(
		Rect2(shape_node.position - size / 2.0, size),
		door_color
	)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# Reuse the player's is_dead flag so the player freezes
	# and drones can no longer kill them after they escape.
	body.is_dead = true
	body.velocity = Vector2.ZERO

	win_screen.show()
