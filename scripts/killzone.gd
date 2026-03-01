extends Area2D

const GAME_OVER_SOUND = preload("res://assets/sounds/faaah.mp3")
const MAX_RELOAD_DELAY = 2.5

@onready var timer = $Timer

var game_over_player: AudioStreamPlayer
var is_game_over = false

func _ready():
	game_over_player = AudioStreamPlayer.new()
	game_over_player.name = "GameOverSound"
	game_over_player.stream = GAME_OVER_SOUND
	add_child(game_over_player)

func _on_body_entered(body):
	if is_game_over:
		return

	is_game_over = true
	print("You died!")
	Engine.time_scale = 0.5
	body.get_node("CollisionShape2D").queue_free()
	game_over_player.play()

	var reload_delay = timer.wait_time
	if game_over_player.stream:
		reload_delay = clamp(game_over_player.stream.get_length(), timer.wait_time, MAX_RELOAD_DELAY)

	timer.start(reload_delay)


func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
