extends Node3D
class_name BlockyCreatureVisual
## Quadrúpede de caixas estilo Minecraft: corpo, cabeça (no -Z, a frente do
## look_at do CreatureAI), orelhas, cauda e quatro patas com passada diagonal.
## As cores vêm do CreatureData — o mesmo visual serve pro elenco inteiro,
## cada criatura só troca a paleta (dados, não código).

const SWING_SPEED := 10.0
const SWING_AMPLITUDE := 0.7

var moving := false

var _time := 0.0
var _legs: Array[Node3D] = []
var _built := false


func setup(body_color: Color, accent_color: Color) -> void:
	if _built:
		return
	_built = true
	var leg_color := body_color.darkened(0.25)
	for leg_offset in [
		Vector3(-0.16, 0.3, -0.24), Vector3(0.16, 0.3, -0.24),
		Vector3(-0.16, 0.3, 0.24), Vector3(0.16, 0.3, 0.24),
	]:
		var leg := BlockBuilder.pivot(self, leg_offset)
		BlockBuilder.box(leg, Vector3(0.14, 0.3, 0.14), Vector3(0, -0.15, 0), leg_color)
		_legs.append(leg)

	BlockBuilder.box(self, Vector3(0.5, 0.35, 0.8), Vector3(0, 0.46, 0), body_color)
	BlockBuilder.box(self, Vector3(0.34, 0.32, 0.3), Vector3(0, 0.62, -0.52), body_color)
	BlockBuilder.box(self, Vector3(0.09, 0.14, 0.05), Vector3(-0.1, 0.82, -0.5), accent_color)
	BlockBuilder.box(self, Vector3(0.09, 0.14, 0.05), Vector3(0.1, 0.82, -0.5), accent_color)
	BlockBuilder.box(self, Vector3(0.12, 0.12, 0.34), Vector3(0, 0.55, 0.5), accent_color)
	BlockBuilder.box(self, Vector3(0.06, 0.06, 0.03), Vector3(-0.08, 0.66, -0.68), Color(0.1, 0.1, 0.12))
	BlockBuilder.box(self, Vector3(0.06, 0.06, 0.03), Vector3(0.08, 0.66, -0.68), Color(0.1, 0.1, 0.12))


func _process(delta: float) -> void:
	if _legs.is_empty():
		return
	_time += delta
	var swing: float = sin(_time * SWING_SPEED) * SWING_AMPLITUDE if moving else 0.0
	# passada diagonal: frente-esquerda anda junto com trás-direita
	_legs[0].rotation.x = lerp_angle(_legs[0].rotation.x, swing, 12.0 * delta)
	_legs[3].rotation.x = lerp_angle(_legs[3].rotation.x, swing, 12.0 * delta)
	_legs[1].rotation.x = lerp_angle(_legs[1].rotation.x, -swing, 12.0 * delta)
	_legs[2].rotation.x = lerp_angle(_legs[2].rotation.x, -swing, 12.0 * delta)
