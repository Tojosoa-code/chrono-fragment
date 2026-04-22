class_name PlayerStateRun extends PlayerState

func init() -> void:
	pass

func enter() -> void:
	player.animation_player.play("Run")
	pass

func exit() -> void :
	pass

func handle_input(event : InputEvent) -> PlayerState :
	if event.is_action_pressed("jump") and player.is_on_floor() :
		return jump
	if event.is_action_pressed("dash") and player.can_dash:
		return dash
	return next_state

func process(_delta: float) -> PlayerState:
	if player.direction.x == 0 :
		return idle
	elif player.direction.y > 0.5 :
		return crouch
	return next_state

func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = player.direction.x * player.SPEED
	if not player.is_on_floor() :
		return fall
	return next_state
