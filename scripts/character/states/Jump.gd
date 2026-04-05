class_name PlayerStateJump extends PlayerState

func init() -> void:
	pass

func enter() -> void:
	player.velocity.y = player.JUMP_VELOCITY
	pass

func exit() -> void :
	pass

func handle_input(event : InputEvent) -> PlayerState :
	if event.is_action_released("jump") :
		player.velocity.y *= 0.5
		return fall
	if event.is_action_pressed("surcharge") :
		return surcharge
	return next_state

func process(_delta: float) -> PlayerState:
	return next_state

func physics_process(_delta: float) -> PlayerState:
	if player.velocity.y >= 0.0 :
		return fall
	player.velocity.x = player.direction.x * player.SPEED
	return next_state
