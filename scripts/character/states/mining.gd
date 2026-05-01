class_name PlayerStateMining
extends PlayerState

func init() -> void:
	pass

func enter() -> void:
	player.mining_progress = 0.0
	player.current_tile = player.get_hovered_tile()

func exit() -> void:
	player.mining_progress = 0.0
	player.current_tile = Vector2i(-9999, -9999)

func handle_input(event: InputEvent) -> PlayerState:
	if event.is_action_released("mine"):
		return idle
	return next_state

func process(delta: float) -> PlayerState:
	if not Input.is_action_pressed("mine"):
		return idle
	if not player.is_in_mining_range():
		return idle

	var tuile := player.get_hovered_tile()
	var durete = player.tile_map.get_block_hardness(tuile)
	if durete == 0.0:
		return idle

	if tuile != player.current_tile:
		_reset_visuel(player.current_tile)
		player.mining_progress = 0.0
		player.current_tile = tuile
		player.mining_timer = 0.0

	player.mining_timer += delta
	if player.mining_timer >= player.mining_speed:
		player.mining_timer = 0.0
		player.mining_progress += 1
		_do_hit_effect()
		@warning_ignore("narrowing_conversion")
		_mettre_a_jour_visuel(tuile, player.mining_progress)
		if player.mining_progress >= durete:
			player.tile_map.break_block(tuile)
			player.mining_progress = 0.0
			player.current_tile = Vector2i(-9999, -9999)
			_do_break_effect()

	return next_state

func physics_process(_delta: float) -> PlayerState:
	return next_state

func _mettre_a_jour_visuel(pos: Vector2i, coups: int) -> void:
	var atlas = player.tile_map.get_cell_atlas_coords(pos)
	if atlas == Vector2i(-1, -1):
		return
	var data = BlockData.get_data(atlas)
	if data.is_empty():
		return
	var nouvel_atlas = BlockData.get_etat_visuel(data, coups)
	if nouvel_atlas != Vector2i(-1, -1):
		player.tile_map.set_cell(pos, 0, nouvel_atlas)

func _reset_visuel(pos: Vector2i) -> void:
	if pos == Vector2i(-9999, -9999):
		return
	var atlas = player.tile_map.get_cell_atlas_coords(pos)
	if atlas == Vector2i(-1, -1):
		return
	var data = BlockData.get_data(atlas)
	if data.is_empty():
		return
	var etats = data.get("etats", [])
	if not etats.is_empty():
		player.tile_map.set_cell(pos, 0, etats[0])

func _do_hit_effect() -> void:
	var camera = player.get_node("Camera2D") as CameraShake
	var dir = player.get_global_mouse_position() - player.global_position
	camera.tilt(dir)
	camera.zoom_punch(1.05)
	Engine.time_scale = 0.05
	await player.get_tree().create_timer(0.05 * Engine.time_scale).timeout
	Engine.time_scale = 1.0

func _do_break_effect() -> void:
	var camera = player.get_node("Camera2D") as CameraShake
	camera.zoom_punch(1.1)
	Engine.time_scale = 0.05
	await player.get_tree().create_timer(0.08 * Engine.time_scale).timeout
	Engine.time_scale = 1.0
