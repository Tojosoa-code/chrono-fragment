class_name PlayerStateIdle extends PlayerState

func init() -> void:
	pass

func enter() -> void:
	player.animation_player.play("Idle")
	pass

func exit() -> void :
	pass

func handle_input(event : InputEvent) -> PlayerState :
	if event.is_action_pressed("jump") and player.is_on_floor() :
		return jump
	return next_state

func process(_delta: float) -> PlayerState:
	if Input.is_action_pressed("mine") :
		return mining 
	if player.direction.x != 0 : 
		return run
	return next_state

func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	if not player.is_on_floor() :
		return fall
	return next_state
