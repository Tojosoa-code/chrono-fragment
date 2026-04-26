class_name PlayerStateJump extends PlayerState

func init() -> void:
	pass

func enter() -> void:
	player.animation_player.play("Jump")
	player.animation_player.pause()
	player.velocity.y = player.JUMP_VELOCITY
	pass

func exit() -> void :
	pass

func handle_input(event : InputEvent) -> PlayerState :
	if event.is_action_released("jump") :
		player.velocity.y *= 0.5
		return fall
	return next_state

func process(_delta: float) -> PlayerState:
	set_jump_frame()
	return next_state

func physics_process(_delta: float) -> PlayerState:
	if player.velocity.y >= 0.0 :
		return fall
	player.velocity.x = player.direction.x * player.SPEED
	return next_state

func set_jump_frame() -> void :
	var frame : float = remap(player.velocity.y, player.JUMP_VELOCITY, 0.0, 0.0, 0.5)
	player.animation_player.seek(frame, true)
