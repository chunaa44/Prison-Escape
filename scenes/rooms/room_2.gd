extends Node2D

@export var left_limit: float = 18.0
@export var exit_x: float = 380.0   # walk past this to finish

@onready var player: CharacterBody2D = $Player
@onready var death_screen: Control = $GameUI/DeathScreen
@onready var win_screen: Control = $GameUI/WinScreen

var finished: bool = false


func _ready() -> void:
	player.death_screen = death_screen

	for button in [
		$GameUI/DeathScreen/VBoxContainer/RestartButton,
		$GameUI/WinScreen/VBoxContainer/RestartButton,
	]:
		if not button.pressed.is_connected(_on_restart_button_pressed):
			button.pressed.connect(_on_restart_button_pressed)


func _physics_process(_delta: float) -> void:
	if finished or player.is_dead:
		return

	if player.global_position.x < left_limit:
		player.global_position.x = left_limit

	if player.global_position.x >= exit_x:
		finished = true
		player.is_dead = true
		player.velocity = Vector2.ZERO
		win_screen.show()


func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
