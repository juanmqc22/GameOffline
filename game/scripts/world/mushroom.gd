extends Node3D
## Cogumelo-azul: cresce perto de árvores, some ao coletar e renasce no dia
## seguinte. É a comida favorita do Brum (ver resources/creatures/brum.tres).

const RESPAWN_HOURS := 24

var is_available := true

var _hours_since_collect := 0


func _ready() -> void:
	add_to_group("mushroom")
	BlockBuilder.box(self, Vector3(0.14, 0.28, 0.14), Vector3(0, 0.14, 0), Color(0.85, 0.8, 0.7))
	BlockBuilder.box(self, Vector3(0.34, 0.14, 0.34), Vector3(0, 0.33, 0), Color(0.25, 0.45, 0.85))
	TimeManager.hour_passed.connect(_on_hour_passed)


func collect() -> void:
	is_available = false
	visible = false
	_hours_since_collect = 0


func _on_hour_passed(_game_hour: float) -> void:
	if is_available:
		return
	_hours_since_collect += 1
	if _hours_since_collect >= RESPAWN_HOURS:
		is_available = true
		visible = true
