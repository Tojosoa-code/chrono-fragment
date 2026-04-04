class_name Player
extends CharacterBody2D

#region // VARIABLE EXPORTATION
@export var label : Label
#endregion

 #region // VARIABLE ONREADY
@onready var STATES: Node = %States
#endregion

#region // VARIABLE CONSTANT
const SPEED := 250
const JUMP_VELOCITY = -350.0
#endregion

#region // VARIABLE STATE MACHINE
var states : Array[PlayerState]
var current_state : PlayerState :
	get : return states.front()
var previous_state : PlayerState :
	get : return states[1]
#endregion

#region // VARIABLE STANDART
var direction : Vector2 = Vector2.ZERO
var gravity : float = 980
#endregion

func _ready() -> void:
	initialize_state()

func _unhandled_input(event: InputEvent) -> void:
	change_state(current_state.handle_input(event))

func _process(delta: float) -> void:
	update_direction()
	change_state(current_state.process(delta))

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	change_state(current_state.physics_process(delta))
	move_and_slide()

func initialize_state() -> void :
	states = []
	for stt in STATES.get_children() :
		if stt is PlayerState :
			states.append(stt) 
			stt.player = self
	print(states)
	if states.size() == 0 :
		print("Aucune State!")
		return
	for state in states :
		state.init()
	update_label()
	current_state.enter()

func change_state(new_state : PlayerState) -> void :
	if new_state == null or current_state == new_state :
		return
	if current_state :
		current_state.exit()
	states.push_front(new_state)
	current_state.enter()
	update_label()
	states.resize(3)

func update_direction() -> void :
	#var prev_direction : Vector2 = direction
	var axis_x := Input.get_axis("move_left", "move_right")
	var axis_y := Input.get_axis("move_top", "move_down")
	direction = Vector2(axis_x, axis_y)

func update_label() -> void :
	if label :
		label.text = current_state.name
	else :
		print("Label non assigné pour la debug")
