class_name PlayerStateDash extends PlayerState

var dash_timer := 0.0

func init() -> void:
	pass

func enter() -> void:
	player.animation_player.play("Dash")
	player.can_dash = false
	dash_timer = player.DASH_DURATION
	var input_dir = Input.get_vector("move_left", "move_right", "move_top", "move_down")
	if input_dir == Vector2.ZERO:
		input_dir = Vector2.RIGHT if player.direction.x >= 0 else Vector2.LEFT
	player.velocity = input_dir.normalized() * player.DASH_VELOCITY

func exit() -> void :
	player.velocity *= 0.5

func handle_input(_event : InputEvent) -> PlayerState :
	return next_state

func process(_delta: float) -> PlayerState:
	return next_state

func physics_process(delta: float) -> PlayerState:
	dash_timer -= delta
	if dash_timer <= 0:
		if player.is_on_floor():
			return idle
		else:
			return fall
	return next_state
