class_name PlayerState extends Node

#region // VARIABLES STANDART
var player : Player
var next_state : PlayerState
#endregion

#region // REFERENCES A TOUS LES STATES
@onready var idle: PlayerStateIdle = %Idle
@onready var run: PlayerStateRun = %Run
@onready var jump: PlayerStateJump = %Jump
@onready var fall: PlayerStateFall = %Fall
@onready var dash: PlayerStateDash = %Dash
@onready var crouch: PlayerStateCrouch = %Crouch
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
