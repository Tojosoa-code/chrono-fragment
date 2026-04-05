class_name PlayerStateSurcharge extends PlayerState

const TIME_SCALE := 0.05
const DURATION := 1.5
var elapsed_time := 0.0

func init() -> void:
	pass

func enter() -> void:
	Engine.time_scale = TIME_SCALE
	elapsed_time = 0.0

func exit() -> void :
	Engine.time_scale = 1

func handle_input(_event : InputEvent) -> PlayerState :
	return next_state

func process(_delta: float) -> PlayerState:
	return next_state

func physics_process(delta: float) -> PlayerState:
	var real_delta = delta / Engine.time_scale
	elapsed_time += real_delta
	if elapsed_time >= DURATION :
		return dash
	return next_state
