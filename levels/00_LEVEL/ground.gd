extends TileMapLayer

# --- Paramètres du monde ---
@export var taille_chunk = 32
@export var limite_surface = 10
@export var seuil_grotte = 0.05
@onready var player = %Player

# --- Gestion du Monde ---
var noise = FastNoiseLite.new()
var noise_richesse = FastNoiseLite.new()
var chunks_generes = {}
var file_attente_dessin = []

# --- Thread ---
var thread: Thread = null
var mutex = Mutex.new()
var chunks_en_attente_generation = [] # Liste des chunks à générer (protégée par mutex)
var generation_en_cours = false

func _ready():
	noise.seed = randi()
	noise.frequency = 0.05
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX

	noise_richesse.seed = noise.seed + 1
	noise_richesse.frequency = 0.001
	noise_richesse.noise_type = FastNoiseLite.TYPE_SIMPLEX

func _process(_delta: float) -> void:
	var p_pos = player.global_position
	var curr_chunk_x = int(floor(p_pos.x / (taille_chunk * 32)))  # 32 = taille d'une tile en pixels
	var curr_chunk_y = int(floor(p_pos.y / (taille_chunk * 32)))

	# 1. Collecter les chunks manquants
	for dx in range(-2, 3):
		for dy in range(-2, 3):
			var cible = Vector2i(curr_chunk_x + dx, curr_chunk_y + dy)
			if not chunks_generes.has(cible):
				chunks_generes[cible] = true  # Réserver tout de suite pour éviter les doublons
				mutex.lock()
				chunks_en_attente_generation.append(cible)
				mutex.unlock()

	# 2. Lancer le thread si libre
	if not generation_en_cours and chunks_en_attente_generation.size() > 0:
		mutex.lock()
		var prochain = chunks_en_attente_generation.pop_front()
		mutex.unlock()

		generation_en_cours = true
		thread = Thread.new()
		thread.start(_thread_generer_chunk.bind(prochain))

	# 3. Vérifier si le thread a fini
	if generation_en_cours and thread != null and not thread.is_alive():
		thread.wait_to_finish()
		generation_en_cours = false
		thread = null

	# 4. Dessiner UN chunk par frame pour éviter les gros pics
	if file_attente_dessin.size() > 0:
		mutex.lock()
		var donnees = file_attente_dessin.pop_front()
		mutex.unlock()
		appliquer_dessin_chunk(donnees)

# Appelée depuis le thread secondaire
func _thread_generer_chunk(pos_chunk: Vector2i):
	var donnees = generer_donnees_chunk(pos_chunk)
	mutex.lock()
	file_attente_dessin.append(donnees)
	mutex.unlock()

func generer_donnees_chunk(pos_chunk: Vector2i) -> Dictionary:
	var minerai_dict = {}
	var terre_liste = []

	# Richesse locale du chunk (entre -1 et 1)
	var richesse = noise_richesse.get_noise_2d(pos_chunk.x, pos_chunk.y)

	for x_local in range(taille_chunk):
		for y_local in range(taille_chunk):
			var x_global = (pos_chunk.x * taille_chunk) + x_local
			var y_global = (pos_chunk.y * taille_chunk) + y_local
			var pos_g = Vector2i(x_global, y_global)

			if not est_de_la_roche(pos_g):
				continue
			if minerai_dict.has(pos_g):
				continue

			var chance = randf()
			var profondeur = max(0, y_global - limite_surface)

			# --- Équilibrage par profondeur ---
			# Charbon : couche supérieure, commun
			var seuil_charbon = lissage(profondeur, 20, 100, 0.06, 0.0)
			# Fer : couche moyenne
			var seuil_fer    = lissage(profondeur, 50, 200, 0.04, 0.0)
			# Or : couche profonde
			var seuil_or     = lissage(profondeur, 150, 400, 0.025, 0.0)
			# Diamant : très profond seulement
			var seuil_diamant = lissage(profondeur, 300, 600, 0.01, 0.0)

			# Bonus de richesse : zone riche = +30% sur les seuils
			var bonus = richesse * 0.3

			if chance < (seuil_diamant + seuil_diamant * bonus):
				creer_filon(pos_g, "diamant", minerai_dict, pos_chunk)
			elif chance < (seuil_or + seuil_or * bonus):
				creer_filon(pos_g, "or", minerai_dict, pos_chunk)
			elif chance < (seuil_fer + seuil_fer * bonus):
				creer_filon(pos_g, "fer", minerai_dict, pos_chunk)
			elif chance < (seuil_charbon + seuil_charbon * bonus):
				creer_filon(pos_g, "charbon", minerai_dict, pos_chunk)
			else:
				terre_liste.append(pos_g)

	# Trier les minerais par type
	var final_charbon = []
	var final_fer = []
	var final_or = []
	var final_diamant = []

	for pos in minerai_dict:
		match minerai_dict[pos]:
			"charbon":  final_charbon.append(pos)
			"fer":      final_fer.append(pos)
			"or":       final_or.append(pos)
			"diamant":  final_diamant.append(pos)

	return {
		"terre": terre_liste,
		"charbon": final_charbon,
		"fer": final_fer,
		"or": final_or,
		"diamant": final_diamant
	}

# Fonction de lissage : le seuil monte de 0 à valeur_max entre profondeur_min et profondeur_max
func lissage(profondeur: float, prof_min: float, prof_max: float, valeur_max: float, valeur_min: float) -> float:
	if profondeur < prof_min: return valeur_min
	if profondeur > prof_max: return valeur_max
	var t = (profondeur - prof_min) / (prof_max - prof_min)
	return lerp(valeur_min, valeur_max, t)

func creer_filon(pos_depart: Vector2i, type: String, minerai_dict: Dictionary, pos_chunk: Vector2i):
	# Taille du filon selon le type
	var taille = match_taille_filon(type)
	var pos_actuelle = pos_depart

	var x_min = pos_chunk.x * taille_chunk
	var x_max = x_min + taille_chunk - 1
	var y_min = pos_chunk.y * taille_chunk
	var y_max = y_min + taille_chunk - 1

	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for i in range(taille):
		if pos_actuelle.x >= x_min and pos_actuelle.x <= x_max and \
		   pos_actuelle.y >= y_min and pos_actuelle.y <= y_max:
			if est_de_la_roche(pos_actuelle) and not minerai_dict.has(pos_actuelle):
				minerai_dict[pos_actuelle] = type
		pos_actuelle += directions[randi() % directions.size()]

func match_taille_filon(type: String) -> int:
	match type:
		"charbon":  return randi_range(6, 16)
		"fer":      return randi_range(5, 12)
		"or":       return randi_range(3, 8)
		"diamant":  return randi_range(2, 5)
		_:          return randi_range(3, 8)

func est_de_la_roche(pos_g: Vector2i) -> bool:
	if pos_g.y <= limite_surface: return false
	var v = noise.get_noise_2d(pos_g.x, pos_g.y)
	return v > (seuil_grotte + (pos_g.y * 0.00005))

func appliquer_dessin_chunk(data: Dictionary):
	set_cells_terrain_connect(data["terre"], 0, 0)
	# Adapte les Vector2i selon ton atlas
	for pos in data["charbon"]: set_cell(pos, 0, Vector2i(10, 1))
	for pos in data["fer"]:     set_cell(pos, 0, Vector2i(2, 5))
	for pos in data["or"]:      set_cell(pos, 0, Vector2i(1, 5))
	for pos in data["diamant"]: set_cell(pos, 0, Vector2i(8, 5))

func get_block_hardness(tile_pos: Vector2i) -> float:
	var atlas_coords = get_cell_atlas_coords(tile_pos)
	if atlas_coords == Vector2i(-1, -1):
		return 0.0  # Case vide
	var data = BlockData.get_data(atlas_coords)
	if data.is_empty():
		return 1.5  # C'est de la pierre
	return data.get("hardness", 0.0)

func get_block_data(tile_pos: Vector2i) -> Dictionary:
	var atlas_coords = get_cell_atlas_coords(tile_pos)
	if atlas_coords == Vector2i(-1, -1):
		return {}
	var data = BlockData.get_data(atlas_coords)
	if data.is_empty():
		return {  # Terre
			"nom": "terre",
			"hardness": 1.5,
			"valeur": 0,
			"niveau_pioche_min": 0
		}
	return data
	
func break_block(tile_pos: Vector2i) -> Dictionary:
	var data = get_block_data(tile_pos)
	
	erase_cell(tile_pos)
	
	var voisins_pierre = []
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var voisin = tile_pos + Vector2i(dx, dy)
			var voisin_data = get_block_data(voisin)
			if not voisin_data.is_empty() and voisin_data.get("nom") == "terre":
				voisins_pierre.append(voisin)
	
	if voisins_pierre.size() > 0:
		# Effacer d'abord
		for v in voisins_pierre:
			erase_cell(v)
		# Puis redessiner
		set_cells_terrain_connect(voisins_pierre, 0, 0)
	
	return data
