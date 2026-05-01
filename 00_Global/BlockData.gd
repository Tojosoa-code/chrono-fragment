extends Node

const BLOCS := {
	Vector2i(1, 8): {
		"nom": "charbon",
		"hardness": 2,
		"valeur": 5,
		"niveau_pioche_min": 0,
		"etats": [Vector2i(1, 8), Vector2i(2, 8), Vector2i(3, 8)]
	},
	Vector2i(1, 9): {
		"nom": "fer",
		"hardness": 3,
		"valeur": 20,
		"niveau_pioche_min": 1,
		# CHANGE ATLAS : les 3 états visuels du fer
		"etats": [Vector2i(1, 9), Vector2i(2, 9), Vector2i(3, 9)]
	},
	Vector2i(1, 10): {
		"nom": "or",
		"hardness": 4,
		"valeur": 80,
		"niveau_pioche_min": 2,
		# CHANGE ATLAS : les 3 états visuels de l'or
		"etats": [Vector2i(1, 10), Vector2i(2, 10), Vector2i(3, 10)]
	},
	Vector2i(1, 11): {
		"nom": "diamant",
		"hardness": 5,
		"valeur": 250,
		"niveau_pioche_min": 3,
		# CHANGE ATLAS : les 3 états visuels du diamant
		"etats": [Vector2i(1, 11), Vector2i(2, 11), Vector2i(3, 11)]
	},
}

func get_data(atlas_coords: Vector2i) -> Dictionary:
	# Cherche le bloc par son état initial (colonne 0 uniquement)
	for cle in BLOCS:
		var bloc = BLOCS[cle]
		if atlas_coords in bloc["etats"]:
			return bloc
	return {}

func get_etat_visuel(data: Dictionary, coups: int) -> Vector2i:
	var hardness = data.get("hardness", 1)
	var etats = data.get("etats", [])
	if etats.is_empty():
		return Vector2i(-1, -1)
	
	if hardness >= 3:
		# 3 états : normal → cassé1 → cassé2
		var index = clamp(coups, 0, 2)
		return etats[index]
	elif hardness == 2:
		# 2 états : normal → cassé2 (on saute cassé1)
		if coups == 0: return etats[0]
		else: return etats[2]
	else:
		# 1 coup : on ne change pas l'image
		return etats[0]
