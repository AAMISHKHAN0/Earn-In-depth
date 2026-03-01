extends CharacterBody2D

# Movement Constants
const SPEED = 130.0
const ACCELERATION = 800.0
const FRICTION = 1000.0

# Jump Constants
const JUMP_VELOCITY = -300.0
const JUMP_CUT_MULTIPLIER = 0.5 # How much upward velocity is kept if jump reliesed early
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.1

# Dash Constants
const DASH_SPEED = 350.0
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 1.0

# Gravity
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# State Variables
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var facing_direction = 1 # 1 for right, -1 for left

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Handle Timers
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
		
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
		
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
		
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			velocity.y = 0 # Optional: Stop floating after dash
	
	# Add Gravity (if not dashing)
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta

	# Handle Jump Input Buffering
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

	# Execute Jump
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0
		
	# Variable Jump Height
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER

	# Get Horizontal Input Direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Update Facing Direction for Dash and Sprite
	if direction != 0:
		facing_direction = sign(direction)
	
	# Handle Dash Input
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and not is_dashing:
		is_dashing = true
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN
		velocity.y = 0 # Keep player horizontal during dash
		velocity.x = facing_direction * DASH_SPEED

	# Movement & Physics Logic
	if not is_dashing:
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

	# Flip Sprite
	if facing_direction > 0:
		animated_sprite.flip_h = false
	elif facing_direction < 0:
		animated_sprite.flip_h = true
	
	# Play Animations
	if is_on_floor():
		if velocity.x == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	move_and_slide()
