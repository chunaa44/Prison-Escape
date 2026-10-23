extends Node2D

@export var scan_speed: float = 30.0
@export var scan_range: float = 35.0   # degrees to each side

var scan_direction: float = 1.0
var start_rotation: float = 0.0

@onready var vision_cone: Node2D = $VisionCone


func _ready() -> void:
	start_rotation = vision_cone.rotation
	$AnimatedSprite2D.play("drone_idle")


func _process(delta: float) -> void:
	vision_cone.rotation += deg_to_rad(scan_speed) * scan_direction * delta

	var offset := vision_cone.rotation - start_rotation

	if offset > deg_to_rad(scan_range):
		scan_direction = -1.0
	elif offset < deg_to_rad(-scan_range):
		scan_direction = 1.0
