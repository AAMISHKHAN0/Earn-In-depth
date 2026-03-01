extends Node2D
class_name LevelSpawner

@export var chunk_scenes: Array[PackedScene] = []
@export var chunk_width: float = 1000.0
@export var start_chunks: int = 3
@export var spawn_buffer: float = 1500.0 # How far ahead of the player to spawn chunks
@export var cleanup_distance: float = 2000.0 # How far behind the player to destroy chunks

var spawned_chunks: Array[Node2D] = []
var next_spawn_x: float = 0.0
var player: Node2D

func _ready():
	# Wait for a frame to ensure player is ready
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		push_error("LevelSpawner: No node in group 'player' found!")
		return
		
		
	# Spawn initial chunks
	for i in range(start_chunks):
		spawn_chunk(false)

func _process(_delta):
	if player == null:
		return
		
	# Check if we need to spawn a new chunk ahead
	if player.global_position.x + spawn_buffer > next_spawn_x:
		spawn_chunk(true)
		
	# Check if we need to clean up old chunks behind
	cleanup_old_chunks()

func spawn_chunk(scale_difficulty: bool):
	var chunk_instance: Node2D
	
	if chunk_scenes.is_empty():
		# AUTOMATIC FALLBACK: Create a generic chunk out of thin air if the user hasn't set one up!
		chunk_instance = Node2D.new()
		chunk_instance.name = "AutoChunk"
		
		# Try to duplicate the existing level's TileMap to act as the ground
		var existing_tilemap = get_tree().current_scene.get_node_or_null("TileMap")
		if existing_tilemap:
			var duplicated_tilemap = existing_tilemap.duplicate()
			# Reset position for the new chunk relative to the chunk instance origin
			duplicated_tilemap.global_position = Vector2.ZERO 
			chunk_instance.add_child(duplicated_tilemap)
			
		# Optional: duplicate coins/platforms too, but keep it simple for now
	else:
		# Normally, instantiate the pre-made scene the user assigned in the inspector
		var random_index = randi() % chunk_scenes.size()
		chunk_instance = chunk_scenes[random_index].instantiate() as Node2D
	
	# Position the chunk
	chunk_instance.global_position = Vector2(next_spawn_x, 0)
	
	# Optional: Interface with Chunk script to scale difficulty (e.g., spawn more enemies)
	if scale_difficulty and chunk_instance.has_method("apply_difficulty"):
		var gm = get_tree().current_scene.get_node_or_null("%GameManager")
		if gm != null:
			chunk_instance.apply_difficulty(gm.difficulty_multiplier)
	
	# Add to scene tree and track it
	add_child(chunk_instance)
	spawned_chunks.append(chunk_instance)
	
	# Advance the spawn point for the next chunk
	next_spawn_x += chunk_width

func cleanup_old_chunks():
	# Iterate backwards to safely remove from array while looping
	for i in range(spawned_chunks.size() - 1, -1, -1):
		var chunk = spawned_chunks[i]
		if is_instance_valid(chunk):
			# If the chunk is far behind the player, delete it
			if player.global_position.x - chunk.global_position.x > cleanup_distance:
				chunk.queue_free()
				spawned_chunks.remove_at(i)
