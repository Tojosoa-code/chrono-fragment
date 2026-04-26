class_name CameraShake
extends Camera2D

var shake_strength := 0.0
var shake_decay := 8.0   # Vitesse à laquelle ça s'arrête
var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func _process(delta: float) -> void:
	if shake_strength > 0.0:
		offset = Vector2(
			rng.randf_range(-shake_strength, shake_strength),
			rng.randf_range(-shake_strength, shake_strength)
		)
		shake_strength = lerpf(shake_strength, 0.0, shake_decay * delta)
	else:
		offset = Vector2.ZERO

# Appelle ça depuis le state Mining
func shake(strength: float) -> void:
	shake_strength = strength
