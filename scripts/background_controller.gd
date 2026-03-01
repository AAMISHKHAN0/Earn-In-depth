extends CanvasLayer
class_name BackgroundController

@export var background_rect: ColorRect
@export var sky_gradient: Gradient
@export var cycle_distance: float = 20000.0 # How far player runs to go from Morning -> Night

var player: Node2D

func _ready():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		push_error("BackgroundController: No node in group 'player' found!")
	if background_rect == null:
		push_error("BackgroundController: background_rect is not assigned!")
	if sky_gradient == null:
		push_error("BackgroundController: sky_gradient is not assigned!")

func _process(_delta):
	if player == null or background_rect == null or sky_gradient == null:
		return
		
	# Calculate normalized progress (0.0 to 1.0) based on distance
	var progress = clamp(player.global_position.x / cycle_distance, 0.0, 1.0)
	
	# Sample the gradient at the current progress
	var current_color = sky_gradient.sample(progress)
	
	# Apply the color
	background_rect.color = current_color
