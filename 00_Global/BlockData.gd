# BlockData.gd (Autoload, nom : BlockData)
extends Node

# Clé = Vector2i de l'atlas tile  →  {hardness, nom, valeur}
const BLOCS := {
	Vector2i(0, 0): {  # Terre
		"nom": "terre",
		"hardness": 1.5,
		"valeur": 0,
		"niveau_pioche_min": 0
	},
	Vector2i(10, 1): {  # Charbon
		"nom": "charbon",
		"hardness": 2.0,
		"valeur": 5,
		"niveau_pioche_min": 0
	},
	Vector2i(2, 5): {  # Fer
		"nom": "fer",
		"hardness": 3.5,
		"valeur": 20,
		"niveau_pioche_min": 1
	},
	Vector2i(1, 5): {  # Or
		"nom": "or",
		"hardness": 5.0,
		"valeur": 80,
		"niveau_pioche_min": 2
	},
	Vector2i(8, 5): {  # Diamant
		"nom": "diamant",
		"hardness": 8.0,
		"valeur": 250,
		"niveau_pioche_min": 3
	},
}

func get_data(atlas_coords: Vector2i) -> Dictionary:
	return BLOCS.get(atlas_coords, {})
