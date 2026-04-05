class_name Player
extends CharacterBody2D

#region // VARIABLE EXPORTATION
@export var label : Label
@export var DASH_POWER : float = 500.0
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
	if current_state is PlayerStateSurcharge:
		queue_redraw()
	elif previous_state and previous_state is PlayerStateSurcharge:
		queue_redraw()
	change_state(current_state.process(delta))

func _physics_process(delta: float) -> void:
	if not current_state is PlayerStateDash :
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


#region // DRAW FUNCTION
func _draw() -> void :
	if current_state is PlayerStateSurcharge :
		update_trajectory()

func get_forward_direction() -> Vector2 :
	return global_position.direction_to(get_global_mouse_position())

func update_trajectory() -> void :
	# On crée une copie locale pour la simulation
	var sim_velocity : Vector2 = DASH_POWER * get_forward_direction() 
	var line_start := global_position
	var line_end : Vector2
	var drag : float = ProjectSettings.get_setting("physics/2d/default_linear_damp")
	var timestep := 0.02
	var colors := [Color.YELLOW, Color.TRANSPARENT]
	
	for i : int in 70:
		sim_velocity.y += gravity * timestep
		sim_velocity = sim_velocity * clampf(1.0 - drag * timestep, 0, 1)
		line_end = line_start + (sim_velocity * timestep)
		
		var ray := raycast_query2d(line_start, line_end)
		if not ray.is_empty():
			draw_line_global(line_start, ray.position, colors[i%2], 2)
			break
		
		draw_line_global(line_start, line_end, colors[i%2], 2)
		line_start = line_end

func raycast_query2d(pointA, pointB) -> Dictionary :
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(pointA, pointB, 1)
	
	# CRITIQUE : L'exclusion doit être définie AVANT de lancer l'intersection
	query.exclude = [self.get_rid()]
	
	var result := space_state.intersect_ray(query)
	
	if result:
		return result
	return {}

func draw_line_global(pointA : Vector2, pointB : Vector2, color : Color, width : int = 1) -> void :
	var local_offset := pointA - global_position
	var pointB_local := pointB - global_position
	draw_line(local_offset, pointB_local, color, width)
#endregion
