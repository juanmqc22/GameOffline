extends Node3D
class_name BlockyPlayerVisual
## Boneco de caixas estilo Minecraft: cabeça, tronco, braços e pernas em
## BoxMesh, com balanço simples de membros ao andar. Origem nos pés — o
## player_controller gira este nó pra direção do movimento (o corpo físico
## não gira, senão arrastaria a câmera junto).

const COLOR_SKIN := Color(0.87, 0.68, 0.5)
const COLOR_SHIRT := Color(0.16, 0.45, 0.38)
const COLOR_PANTS := Color(0.23, 0.28, 0.42)
const COLOR_EYES := Color(0.12, 0.12, 0.14)

const SWING_SPEED := 9.0
const SWING_AMPLITUDE := 0.8

var moving := false

var _time := 0.0
var _left_leg: Node3D
var _right_leg: Node3D
var _left_arm: Node3D
var _right_arm: Node3D


func _ready() -> void:
	_left_leg = BlockBuilder.pivot(self, Vector3(-0.13, 0.7, 0))
	BlockBuilder.box(_left_leg, Vector3(0.24, 0.7, 0.24), Vector3(0, -0.35, 0), COLOR_PANTS)
	_right_leg = BlockBuilder.pivot(self, Vector3(0.13, 0.7, 0))
	BlockBuilder.box(_right_leg, Vector3(0.24, 0.7, 0.24), Vector3(0, -0.35, 0), COLOR_PANTS)

	BlockBuilder.box(self, Vector3(0.5, 0.7, 0.26), Vector3(0, 1.05, 0), COLOR_SHIRT)

	_left_arm = BlockBuilder.pivot(self, Vector3(-0.35, 1.35, 0))
	BlockBuilder.box(_left_arm, Vector3(0.2, 0.65, 0.2), Vector3(0, -0.28, 0), COLOR_SKIN)
	_right_arm = BlockBuilder.pivot(self, Vector3(0.35, 1.35, 0))
	BlockBuilder.box(_right_arm, Vector3(0.2, 0.65, 0.2), Vector3(0, -0.28, 0), COLOR_SKIN)

	BlockBuilder.box(self, Vector3(0.45, 0.45, 0.45), Vector3(0, 1.63, 0), COLOR_SKIN)
	# olhos no lado -Z: é o "para frente" do look direction
	BlockBuilder.box(self, Vector3(0.08, 0.08, 0.04), Vector3(-0.1, 1.68, -0.235), COLOR_EYES)
	BlockBuilder.box(self, Vector3(0.08, 0.08, 0.04), Vector3(0.1, 1.68, -0.235), COLOR_EYES)


func _process(delta: float) -> void:
	_time += delta
	var swing: float = sin(_time * SWING_SPEED) * SWING_AMPLITUDE if moving else 0.0
	_left_leg.rotation.x = lerp_angle(_left_leg.rotation.x, swing, 12.0 * delta)
	_right_leg.rotation.x = lerp_angle(_right_leg.rotation.x, -swing, 12.0 * delta)
	_left_arm.rotation.x = lerp_angle(_left_arm.rotation.x, -swing, 12.0 * delta)
	_right_arm.rotation.x = lerp_angle(_right_arm.rotation.x, swing, 12.0 * delta)
