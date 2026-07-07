extends CharacterBody3D
class_name CreatureAI
## Utility AI por indivíduo (não por espécie). Ver docs/GDD.md seção 8.2.
## Nenhum modelo treinado: pontuação de ações determinística a partir de
## necessidade + personalidade + memória. Fácil de debugar e ajustar por dados.

enum Action { WANDER, REST, FOLLOW_PLAYER, FLEE, HELP_PLAYER }

@export var data: CreatureData
@export var move_speed: float = 2.5
@export var decision_interval: float = 1.5

const GRAVITY: float = 9.8
const AUTO_JUMP_VELOCITY: float = 5.2 # sobe degraus de 1 bloco do terreno voxel
const FALL_RESET_Y: float = -10.0
const WANDER_RADIUS: float = 8.0
const CALM_COOLDOWN_SECONDS: float = 20.0
const HUNGER_DRAIN_PER_HOUR: float = 2.5

var _player: Node3D = null
var _current_action: Action = Action.WANDER
var _decision_timer: float = 0.0
var _wander_target: Vector3 = Vector3.ZERO
var _home: Vector3 = Vector3.ZERO
var _home_set: bool = false
var _last_calm_seconds: float = -1000.0
var _forced_flee_until: float = -1000.0

@onready var _visual: BlockyCreatureVisual = $Visual


func _ready() -> void:
	if data == null:
		push_warning("CreatureAI (%s): nenhum CreatureData atribuído" % name)
		return
	add_to_group("creature")
	CreatureRegistry.register(data)
	_visual.setup(data.body_color, data.accent_color)
	_player = get_tree().get_first_node_in_group("player")
	TimeManager.hour_passed.connect(_on_hour_passed)


func _physics_process(delta: float) -> void:
	if data == null:
		return
	if data.has_left:
		visible = false
		return

	# o "lar" da criatura é onde ela acordou — capturado no primeiro frame de
	# física porque Main reposiciona todo mundo sobre o terreno no _ready dele
	if not _home_set:
		_home_set = true
		_home = global_position
		_pick_new_wander_target()

	if global_position.y < FALL_RESET_Y:
		global_position = _home + Vector3.UP
		velocity = Vector3.ZERO

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	_decision_timer -= delta
	if _decision_timer <= 0.0:
		_decision_timer = decision_interval
		_current_action = _decide_action()

	_act_on_current_decision(delta)

	if is_on_floor() and is_on_wall() and Vector2(velocity.x, velocity.z).length() > 0.1:
		velocity.y = AUTO_JUMP_VELOCITY

	_visual.moving = Vector2(velocity.x, velocity.z).length() > 0.1
	move_and_slide()


## Pontua cada ação possível e retorna a de maior pontuação.
## Esta função é o lugar certo pra adicionar novas ações no futuro.
func _decide_action() -> Action:
	# pânico após apanhar do jogador sobrepõe qualquer pontuação
	if Time.get_ticks_msec() / 1000.0 < _forced_flee_until:
		return Action.FLEE

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
			var flee_score := (data.flee_threshold - data.trust) * 0.05 * data.flee_weight
			# jogador parado = aproximação calma (GDD seção 9): a criatura
			# tolera quem espera quieto — é assim que se ganha o primeiro contato
			var player_body := _player as CharacterBody3D
			if player_body != null and Vector2(player_body.velocity.x, player_body.velocity.z).length() < 0.1:
				flee_score *= 0.25
			scores[Action.FLEE] = flee_score

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
	var offset := Vector3(randf_range(-WANDER_RADIUS, WANDER_RADIUS), 0.0, randf_range(-WANDER_RADIUS, WANDER_RADIUS))
	_wander_target = _home + offset


## Chamado pelo jogador ao oferecer comida (botão "Agir" com comida na mochila).
func feed(food_id: String) -> void:
	if data == null:
		return
	data.hunger = clampf(data.hunger + 35.0, 0.0, 100.0)
	var is_favorite := food_id != "" and food_id == data.favorite_food_id
	adjust_trust(8.0 if is_favorite else 3.0, "comeu_%s" % food_id)


## Aproximação calma sem comida (GDD seção 9): presença consistente ao longo
## de vários encontros — por isso o cooldown, pra não virar spam de botão.
func calm_approach() -> bool:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_calm_seconds < CALM_COOLDOWN_SECONDS:
		return false
	_last_calm_seconds = now
	adjust_trust(1.5)
	return true


## Atacar uma criatura especial não a mata (morte real vem depois, com muito
## mais peso — GDD 8.4): derruba confiança, grava memória e ela entra em pânico.
func take_hit(_damage: float, _from_position: Vector3) -> void:
	if data == null or data.has_left:
		return
	adjust_trust(-12.0, "fui_atacada_pelo_jogador")
	_forced_flee_until = Time.get_ticks_msec() / 1000.0 + 8.0
	get_tree().call_group("hud", "flash_message",
		"%s foge de você, assustada. Isso não se esquece." % data.display_name)


func _on_hour_passed(_game_hour: float) -> void:
	if data == null or data.has_left:
		return
	data.hunger = maxf(0.0, data.hunger - HUNGER_DRAIN_PER_HOUR)
	# negligência só pesa em quem já confia em você (GDD seção 8.4)
	if data.is_bonded and data.hunger <= 0.0:
		adjust_trust(-1.0, "passou_fome_na_base")


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
	get_tree().call_group("hud", "flash_message",
		"Momento de vínculo: %s agora anda ao seu lado." % data.display_name)
	# TODO: cena de vínculo curta autorada por criatura (GDD seção 9).
