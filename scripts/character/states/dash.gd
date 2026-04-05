class_name PlayerStateDash extends PlayerState

func init() -> void:
	pass

func enter() -> void:
	var launch_direction = player.get_forward_direction()
	player.velocity = launch_direction * player.DASH_POWER
	
	if player.is_on_floor() and launch_direction.y >= 0:
		player.velocity.y = -50

func exit() -> void :
	pass

func handle_input(event : InputEvent) -> PlayerState :
	if event.is_action_pressed("surcharge"):
		return surcharge
	return next_state

func process(_delta: float) -> PlayerState:
	return next_state

func physics_process(delta: float) -> PlayerState:
	player.velocity.y += player.gravity * delta
	var drag : float = ProjectSettings.get_setting("physics/2d/default_linear_damp")
	player.velocity = player.velocity * clampf(1.0 - drag * delta, 0, 1)
	if player.is_on_floor() or player.is_on_wall() :
		return idle
	return next_state
