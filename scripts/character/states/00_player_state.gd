class_name PlayerState extends Node

#region // VARIABLES STANDART
var player : Player
var next_state : PlayerState
#endregion

#region // REFERENCES A TOUS LES STATES

#endregion

func init() -> void:
	pass

func enter() -> void:
	pass

func exit() -> void :
	pass

func handle_input(_event : InputEvent) -> PlayerState :
	return next_state

func process(_delta: float) -> PlayerState:
	return next_state

func physics_process(_delta: float) -> PlayerState:
	return next_state
