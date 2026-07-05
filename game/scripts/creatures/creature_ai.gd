extends CharacterBody3D
class_name CreatureAI
## Utility AI por indivíduo (não por espécie). Ver docs/GDD.md seção 8.2.
## Nenhum modelo treinado: pontuação de ações determinística a partir de
## necessidade + personalidade + memória. Fácil de debugar e ajustar por dados.

enum Action { WANDER, REST, FOLLOW_PLAYER, FLEE, HELP_PLAYER }

@export var data: CreatureData
@export var move_speed: float = 2.5
@export var decision_interval: float = 1.5

var _player: Node3D = null
var _current_action: Action = Action.WANDER
var _decision_timer: float = 0.0
var _wander_target: Vector3 = Vector3.ZERO

const GRAVITY: float = 9.8


func _ready() -> void:
	if data == null:
		push_warning("CreatureAI (%s): nenhum CreatureData atribuído" % name)
		return
	CreatureRegistry.register(data)
	_player = get_tree().get_first_node_in_group("player")
	_pick_new_wander_target()


func _physics_process(delta: float) -> void:
	if data == null or data.has_left:
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	_decision_timer -= delta
	if _decision_timer <= 0.0:
		_decision_timer = decision_interval
		_current_action = _decide_action()

	_act_on_current_decision(delta)
	move_and_slide()


## Pontua cada ação possível e retorna a de maior pontuação.
## Esta função é o lugar certo pra adicionar novas ações no futuro.
func _decide_action() -> Action:
	var scores: Dictionary = {
		Action.WANDER: 1.0, # base — sempre uma opção viável
		Action.REST: (100.0 - data.fatigue) * -0.01 + (data.fatigue * 0.02) * data.rest_weight,
		Action.FOLLOW_PLAYER: 0.0,
		Action.HELP_PLAYER: 0.0,
		Action.FLEE: 0.0,
	}

	scores[Action.WANDER] *= data.explore_weight

	if data.trust < data.flee_threshold and _player != null:
		var distance := global_position.distance_to(_player.global_position)
		if distance < 6.0:
			scores[Action.FLEE] = (data.flee_threshold - data.trust) * 0.05 * data.flee_weight

	if data.is_bonded and _player != null:
		scores[Action.FOLLOW_PLAYER] = 0.6 * data.trust * 0.01
		scores[Action.HELP_PLAYER] = 0.8 * data.trust * 0.01 * data.help_weight

	var best_action: Action = Action.WANDER
	var best_score: float = -INF
	for action in scores.keys():
		if scores[action] > best_score:
			best_score = scores[action]
			best_action = action
	return best_action


func _act_on_current_decision(_delta: float) -> void:
	match _current_action:
		Action.WANDER:
			_move_toward(_wander_target)
			if global_position.distance_to(_wander_target) < 0.5:
				_pick_new_wander_target()
		Action.REST:
			velocity.x = 0.0
			velocity.z = 0.0
			data.fatigue = maxf(0.0, data.fatigue - 5.0 * _delta)
		Action.FOLLOW_PLAYER:
			if _player != null:
				_move_toward(_player.global_position, 2.0)
		Action.HELP_PLAYER:
			if _player != null:
				_move_toward(_player.global_position, 2.0)
		Action.FLEE:
			if _player != null:
				var away := (global_position - _player.global_position).normalized()
				_move_toward(global_position + away * 5.0)


func _move_toward(target: Vector3, stop_distance: float = 0.1) -> void:
	var to_target := target - global_position
	to_target.y = 0.0
	if to_target.length() <= stop_distance:
		velocity.x = 0.0
		velocity.z = 0.0
		return
	var direction := to_target.normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	look_at(global_position + direction, Vector3.UP)


func _pick_new_wander_target() -> void:
	var offset := Vector3(randf_range(-6.0, 6.0), 0.0, randf_range(-6.0, 6.0))
	_wander_target = global_position + offset


## Chamado por eventos de gameplay (alimentar, resgatar, ignorar, atacar).
## Ver docs/GDD.md seção 9 — o que sobe/derruba confiança.
func adjust_trust(amount: float, memory_flag: String = "") -> void:
	if data == null:
		return
	data.trust = clampf(data.trust + amount, 0.0, 100.0)
	if memory_flag != "" and not data.memory_flags.has(memory_flag):
		data.memory_flags.append(memory_flag)
	if not data.is_bonded and data.trust >= data.bond_threshold:
		_trigger_bond_moment()


func _trigger_bond_moment() -> void:
	data.is_bonded = true
	GameState.mark_creature_bonded(data.creature_id)
	# TODO: disparar cena/animação de vínculo específica desta criatura.
	print("Momento de vínculo: %s agora está com você." % data.display_name)
