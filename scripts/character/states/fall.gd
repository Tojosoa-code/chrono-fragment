class_name PlayerStateFall extends PlayerState

const MULTIPLIER := 1.2
var coyote_timer := 0.0
var buffer_timer := 0.0

func init() -> void:
	pass

func enter() -> void:
	player.animation_player.play("Jump")
	player.animation_player.pause()
	player.gravity_multiplier = MULTIPLIER
	if player.previous_state is PlayerStateJump :
		coyote_timer = 0
	else :
		coyote_timer = player.coyote_time
	print(coyote_timer)
	pass

func exit() -> void :
	player.gravity_multiplier = 1.0
	buffer_timer = 0
	pass
	
func handle_input(event : InputEvent) -> PlayerState :
	if event.is_action_pressed("jump") :
		if coyote_timer > 0 :
			return jump
		else :
			buffer_timer = player.jump_buffer_time
	if event.is_action_pressed("mine") :
		return mining 
	return next_state

func process(delta: float) -> PlayerState:
	coyote_timer -= delta
	buffer_timer -= delta
	set_jump_frame()
	return next_state

func physics_process(_delta: float) -> PlayerState:
	if player.is_on_floor() :
		if buffer_timer > 0 and Input.is_action_pressed("jump"):
			return jump
		return idle
	player.velocity.x = player.direction.x * player.SPEED
	return next_state

func set_jump_frame() -> void :
	var frame : float = remap(player.velocity.y, 0.0, player.max_fall_velocity, 0.5, 1.0)
	player.animation_player.seek(frame, true)
