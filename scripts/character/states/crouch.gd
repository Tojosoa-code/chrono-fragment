class_name PlayerStateCrouch extends PlayerState

func init() -> void:
	pass

func enter() -> void:
	player.animation_player.play("Crouch")
	player.collision_shape_crouch.disabled = false
	player.collision_shape_stand.disabled = true
	pass

func exit() -> void :
	player.collision_shape_crouch.disabled = true
	player.collision_shape_stand.disabled = false
	pass

func handle_input(event : InputEvent) -> PlayerState :
	if event.is_action_pressed("jump") :
		if player.one_way_plateformer_detection.is_colliding() :
			player.position.y += 4 
			return fall
		return jump
	return next_state

func process(_delta: float) -> PlayerState:
	if player.direction.y <= 0.5 :
		return idle
	return next_state

func physics_process(delta: float) -> PlayerState:
	player.velocity.x -= player.velocity.x * player.deceleration_rate * delta
	if not player.is_on_floor() :
		return fall
	return next_state
