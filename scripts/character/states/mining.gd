class_name PlayerStateMining
extends PlayerState

var previous_tile

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
	# 1. Si pas dans la portée → retour idle
	if not player.is_in_mining_range() :
		print("Pas dans la porter")
		return idle
	# 2. Récupérer la tuile sous le curseur
	var tuile := player.get_hovered_tile()
	var durete = player.tile_map.get_block_hardness(tuile)
	# 3. Si tuile vide → retour idle
	if durete == 0.0 :
		print("Pas de Bloc")
		return idle
	# 4. Si on change de tuile → reset mining_progress
	if tuile != player.current_tile :
		player.mining_progress = 0.0
		player.current_tile = tuile
	# 5 incrémentation du mining_progress
	player.mining_progress += delta
	# 6. Si mining_progress >= dureté du bloc → casser le bloc
	if player.mining_progress >=  durete :
		player.tile_map.break_block(tuile)
		player.mining_progress = 0.0
		player.current_tile = Vector2i(-9999, -9999)
	return next_state

func physics_process(_delta: float) -> PlayerState:
	return next_state

## --- Helpers ---
#func _camera_shake(strength: float) -> void:
	#var camera = player.get_viewport().get_camera_2d()
	#if camera and camera.has_method("shake"):
		#camera.shake(strength)
#
#func _on_block_broken(data: Dictionary) -> void:
	#if data.is_empty():
		#return
	## Ici tu appelleras ton système d'inventaire plus tard
	#print("Bloc cassé : ", data.get("nom", "?"), " | Valeur : ", data.get("valeur", 0))
	## Shake plus fort quand le bloc cède
	#_camera_shake(5.0)
