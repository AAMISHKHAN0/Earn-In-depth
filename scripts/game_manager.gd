extends Node
# This file should ideally be set up as an AutoLoad singleton named "GameManager"
# Go to Project -> Project Settings -> Autoload to add this script.

signal difficulty_increased

@export var max_difficulty: float = 3.0
@export var difficulty_scale_distance: float = 10000.0 # Distance required to reach max difficulty

var distance_traveled: float = 0.0
var difficulty_multiplier: float = 1.0
var player: Node2D

# Original GameManager Features Restored
var score = 0
@export var score_label: Label

func add_point():
	score += 1
	if score_label:
		score_label.text = "You collected " + str(score) + " coins."

func _ready():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	# AUTOMATIC SCENE SETUP (Bypass manual Inspector work)
	var root = get_tree().current_scene
	if root != null and player != null:
		# Auto-inject Sky Background
		if root.get_node_or_null("AutoSkyCanvas") == null:
			var sky_canvas = CanvasLayer.new()
			sky_canvas.name = "AutoSkyCanvas"
			sky_canvas.layer = -1
			
			var bg_rect = ColorRect.new()
			bg_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			sky_canvas.add_child(bg_rect)
			
			var controller = load("res://scripts/background_controller.gd").new()
			controller.background_rect = bg_rect
			
			var gradient = Gradient.new()
			gradient.add_point(0.0, Color("87CEEB")) # Morning setup
			gradient.add_point(0.5, Color("FFA500")) # Evening setup
			gradient.add_point(1.0, Color("00008B")) # Night setup
			controller.sky_gradient = gradient
			
			sky_canvas.add_child(controller)
			root.add_child(sky_canvas)
			
		# Auto-inject Level Spawner
		if root.get_node_or_null("AutoLevelSpawner") == null:
			var spawner_script = load("res://scripts/level_spawner.gd")
			if spawner_script:
				var spawner = spawner_script.new()
				spawner.name = "AutoLevelSpawner"
				root.add_child(spawner)

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
