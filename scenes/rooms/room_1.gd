extends Node2D

@export var next_room: PackedScene   # leave empty until Room 2 exists
@export var left_limit: float = 18.0
@export var exit_x: float = 380.0    # walk past this to leave the room
@export var fall_y: float = 130.0    # below this the player fell in the pit

@onready var player: CharacterBody2D = $Player

var is_leaving: bool = false


func _physics_process(_delta: float) -> void:
	if is_leaving:
		return

	# Stop the player walking off the left edge of the room.
	if player.global_position.x < left_limit:
		player.global_position.x = left_limit

	# Fell into the pit: restart the room.
	if player.global_position.y > fall_y:
		get_tree().reload_current_scene()
		return

	# Reached the right side: go to the next room.
	if player.global_position.x >= exit_x and next_room != null:
		is_leaving = true
		get_tree().change_scene_to_packed(next_room)
