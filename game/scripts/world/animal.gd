extends CharacterBody3D
## Fauna comum, caçável (GDD seção 10): capivara, cabra, lagarto etc.
## Diferente das criaturas ESPECIAIS (CreatureAI): sem vínculo, sem memória,
## IA mínima (vagar + fugir ao apanhar). Configurada por dicionário vindo do
## VoxelWorld.ANIMAL_SPECIES — espécie nova = entrada nova lá, não código novo.

const GRAVITY := 9.8
const AUTO_JUMP_VELOCITY := 5.2
const FALL_RESET_Y := -10.0
const FLEE_SECONDS := 6.0

var species := "capivara"
var hp := 40.0
var meat := 1
var move_speed := 2.0

var _body_color := Color(0.5, 0.35, 0.2)
var _accent_color := Color(0.35, 0.24, 0.14)
var _visual_scale := 1.0
var _visual: BlockyCreatureVisual
var _home := Vector3.ZERO
var _home_set := false
var _wander_target := Vector3.ZERO
var _decision_timer := 0.0
var _flee_until := 0.0
var _threat_position := Vector3.ZERO


func setup(config: Dictionary) -> void:
	species = config["species"]
	hp = config["hp"]
	meat = config["meat"]
	move_speed = config["speed"]
	_body_color = config["body"]
	_accent_color = config["accent"]
	_visual_scale = config["scale"]


func _ready() -> void:
	add_to_group("animal")
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.0
	shape.shape = capsule
	shape.position = Vector3(0, 0.5, 0)
	add_child(shape)
	_visual = BlockyCreatureVisual.new()
	_visual.setup(_body_color, _accent_color)
	_visual.scale = Vector3.ONE * _visual_scale
	add_child(_visual)


func _physics_process(delta: float) -> void:
	if not _home_set:
		_home_set = true
		_home = global_position
		_pick_wander_target()

	if global_position.y < FALL_RESET_Y:
		global_position = _home + Vector3.UP
		velocity = Vector3.ZERO

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	var now := Time.get_ticks_msec() / 1000.0
	if now < _flee_until:
		var away := (global_position - _threat_position)
		away.y = 0.0
		if away.length() > 0.01:
			_move_toward(global_position + away.normalized() * 6.0, move_speed * 1.8)
	else:
		_decision_timer -= delta
		if _decision_timer <= 0.0:
			_decision_timer = randf_range(2.0, 5.0)
			_pick_wander_target()
		if global_position.distance_to(_wander_target) > 0.6:
			_move_toward(_wander_target, move_speed)
		else:
			velocity.x = 0.0
			velocity.z = 0.0

	if is_on_floor() and is_on_wall() and Vector2(velocity.x, velocity.z).length() > 0.1:
		velocity.y = AUTO_JUMP_VELOCITY

	_visual.moving = Vector2(velocity.x, velocity.z).length() > 0.1
	move_and_slide()


func take_hit(damage: float, from_position: Vector3) -> void:
	hp -= damage
	_flee_until = Time.get_ticks_msec() / 1000.0 + FLEE_SECONDS
	_threat_position = from_position
	if hp <= 0.0:
		_die()


func _die() -> void:
	GameState.add_item("carne", meat)
	get_tree().call_group("hud", "flash_message",
		"Você caçou: %s (+%d carne)." % [species, meat])
	queue_free()


func _move_toward(target: Vector3, speed: float) -> void:
	var to_target := target - global_position
	to_target.y = 0.0
	if to_target.length() < 0.05:
		return
	var direction := to_target.normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	look_at(global_position + direction, Vector3.UP)


func _pick_wander_target() -> void:
	_wander_target = _home + Vector3(randf_range(-7.0, 7.0), 0.0, randf_range(-7.0, 7.0))
