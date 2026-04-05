class_name PlayerStateFall extends PlayerState

func init() -> void:
	pass

func enter() -> void:
	pass

func exit() -> void :
	pass

func handle_input(event : InputEvent) -> PlayerState :
	if event.is_action_pressed("surcharge") :
		return surcharge
	return next_state

func process(_delta: float) -> PlayerState:
	return next_state

func physics_process(_delta: float) -> PlayerState:
	if player.is_on_floor() :
		return idle
	player.velocity.x = player.direction.x * player.SPEED
	return next_state
