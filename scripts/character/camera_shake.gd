class_name CameraShake
extends Camera2D

var rotation_decay := 10.0
var zoom_initial := Vector2(0.25, 0.25)
var zoom_decay := 50.0

func _ready() -> void:
	zoom_initial = zoom

func _process(delta: float) -> void:
	rotation_degrees = lerpf(rotation_degrees, 0.0, rotation_decay * delta)
	zoom = zoom.lerp(zoom_initial, zoom_decay * delta)

func tilt(direction: Vector2) -> void:
	rotation_degrees = sign(direction.x) * -2.5

func zoom_punch(z : float) -> void:
	zoom = zoom_initial * z  # zoom out rapide
