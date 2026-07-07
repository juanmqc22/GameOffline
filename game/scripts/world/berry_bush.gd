extends Node3D
## Arbusto de bagas: coletável com o botão "Agir", rebrota depois de algumas
## horas in-game. Posicionado pelo BlockWorld com seed fixa — estado não vai
## pro save de propósito (rebrotar entre sessões é aceitável no MVP).

const REGROW_HOURS := 12
const BERRIES_PER_HARVEST := 3
const COLOR_LEAVES := Color(0.16, 0.38, 0.18)
const COLOR_BERRY := Color(0.85, 0.15, 0.2)

var has_berries := true

var _hours_since_harvest := 0
var _berry_meshes: Array[MeshInstance3D] = []


func _ready() -> void:
	add_to_group("berry_bush")
	BlockBuilder.box(self, Vector3(0.9, 0.7, 0.9), Vector3(0, 0.35, 0), COLOR_LEAVES)
	for berry_position in [
		Vector3(-0.25, 0.55, -0.46), Vector3(0.2, 0.35, -0.47),
		Vector3(0.46, 0.5, 0.15), Vector3(-0.46, 0.3, 0.2),
		Vector3(0.1, 0.72, 0.3),
	]:
		_berry_meshes.append(BlockBuilder.box(self, Vector3(0.14, 0.14, 0.14), berry_position, COLOR_BERRY))
	TimeManager.hour_passed.connect(_on_hour_passed)


func collect() -> int:
	if not has_berries:
		return 0
	has_berries = false
	_hours_since_harvest = 0
	for mesh in _berry_meshes:
		mesh.visible = false
	return BERRIES_PER_HARVEST


func _on_hour_passed(_game_hour: float) -> void:
	if has_berries:
		return
	_hours_since_harvest += 1
	if _hours_since_harvest >= REGROW_HOURS:
		has_berries = true
		for mesh in _berry_meshes:
			mesh.visible = true
