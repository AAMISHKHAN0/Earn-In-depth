extends Node
# This file should ideally be set up as an AutoLoad singleton named "GameManager"
# Go to Project -> Project Settings -> Autoload to add this script.

signal difficulty_increased

@export var max_difficulty: float = 3.0
@export var difficulty_scale_distance: float = 10000.0 # Distance required to reach max difficulty

var distance_traveled: float = 0.0
var difficulty_multiplier: float = 1.0
var player: Node2D

func _ready():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if player == null:
		return
		
	# Calculate how far the player has run (assuming starting at x=0)
	distance_traveled = max(0.0, player.global_position.x)
	
	# Linearly increase difficulty from 1.0 to max_difficulty based on distance
	var old_difficulty = difficulty_multiplier
	difficulty_multiplier = clamp(1.0 + (distance_traveled / difficulty_scale_distance) * (max_difficulty - 1.0), 1.0, max_difficulty)
	
	# Optional: Emitted so other scripts can react automatically (e.g. increase player speed)
	if old_difficulty != difficulty_multiplier:
		difficulty_increased.emit(difficulty_multiplier)
