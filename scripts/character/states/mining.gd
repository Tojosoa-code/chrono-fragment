class_name PlayerStateMining
extends PlayerState

# Portée de minage en pixels (sans upgrade)
const MINING_RANGE := 80.0

var target_tile := Vector2i(-9999, -9999)
var mining_progress := 0.0
var current_hardness := 0.0
var tile_map : TileMapLayer

# Référence au noeud visuel de progression (on le crée plus bas)
var progress_indicator #: MiningProgressIndicator

func init() -> void:
	# Cherche le TileMap dans le groupe
	var maps = player.get_tree().get_nodes_in_group("tile_map")
	if maps.size() > 0:
		tile_map = maps[0]

func enter() -> void:
	mining_progress = 0.0

func exit() -> void:
	mining_progress = 0.0
	target_tile = Vector2i(-9999, -9999)
	if progress_indicator:
		progress_indicator.hide()

func handle_input(event: InputEvent) -> PlayerState:
	# Relâche le clic → retour idle
	if event.is_action_released("mine"):
		return idle
	return null

func process(delta: float) -> PlayerState:
	if not Input.is_action_pressed("mine"):
		return idle

	if tile_map == null:
		return idle

	# --- Détection du bloc ciblé ---
	var mouse_world_pos = player.get_global_mouse_position()
	var distance = player.global_position.distance_to(mouse_world_pos)

	# Hors portée → retour idle
	if distance > MINING_RANGE:
		return idle

	var tile_pos = tile_map.local_to_map(tile_map.to_local(mouse_world_pos))
	var hardness = tile_map.get_block_hardness(tile_pos)

	# Case vide → retour idle
	if hardness <= 0.0:
		return idle

	# Si on change de bloc → reset la progression
	if tile_pos != target_tile:
		target_tile = tile_pos
		mining_progress = 0.0
		current_hardness = hardness

	# --- Progression du minage ---
	mining_progress += delta

	# Camera shake proportionnel à la progression
	var shake_intensity = lerpf(0.5, 2.5, mining_progress / current_hardness)
	_camera_shake(shake_intensity)

	# --- Bloc cassé ---
	if mining_progress >= current_hardness:
		var block_data = tile_map.break_block(target_tile)
		_on_block_broken(block_data)
		mining_progress = 0.0
		target_tile = Vector2i(-9999, -9999)
		# On reste en état Mining si le joueur maintient le clic
		return null

	return null

func physics_process(_delta: float) -> PlayerState:
	return null

# --- Helpers ---
func _camera_shake(strength: float) -> void:
	var camera = player.get_viewport().get_camera_2d()
	if camera and camera.has_method("shake"):
		camera.shake(strength)

func _on_block_broken(data: Dictionary) -> void:
	if data.is_empty():
		return
	# Ici tu appelleras ton système d'inventaire plus tard
	print("Bloc cassé : ", data.get("nom", "?"), " | Valeur : ", data.get("valeur", 0))
	# Shake plus fort quand le bloc cède
	_camera_shake(5.0)
