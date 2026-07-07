extends CharacterBody3D
## Vulto: a ameaça noturna (GDD seção 10). Aparece quando escurece, persegue o
## jogador e some ao amanhecer. Derrotá-lo rende cristal — risco/recompensa de
## sair (ou ficar fora) à noite. Spawnado pelo MonsterSpawner; nunca persiste.

const GRAVITY := 9.8
const AUTO_JUMP_VELOCITY := 5.2
const CHASE_RANGE := 18.0
const ATTACK_RANGE := 1.4
const ATTACK_COOLDOWN := 1.5
const CONTACT_DAMAGE := 10.0

var hp := 50.0
var move_speed := 3.2

var _visual: BlockyCreatureVisual
var _player: Node3D = null
var _attack_timer := 0.0
var _wander_target := Vector3.ZERO
var _decision_timer := 0.0


func _ready() -> void:
	add_to_group("monster")
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.0
	shape.shape = capsule
	shape.position = Vector3(0, 0.5, 0)
	add_child(shape)
	_visual = BlockyCreatureVisual.new()
	_visual.setup(Color(0.12, 0.1, 0.16), Color(0.5, 0.2, 0.6))
	_visual.scale = Vector3.ONE * 1.1
	add_child(_visual)
	_player = get_tree().get_first_node_in_group("player")
	_wander_target = global_position


func _physics_process(delta: float) -> void:
	if not TimeManager.is_night():
		queue_free() # o dia desfaz o vulto
		return
	if global_position.y < -10.0:
		queue_free()
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	_attack_timer = maxf(0.0, _attack_timer - delta)

	if _player != null:
		var distance := global_position.distance_to(_player.global_position)
		if distance <= ATTACK_RANGE:
			velocity.x = 0.0
			velocity.z = 0.0
			if _attack_timer <= 0.0:
				_attack_timer = ATTACK_COOLDOWN
				GameState.damage_player(CONTACT_DAMAGE)
				get_tree().call_group("hud", "flash_message", "Um vulto te atingiu!")
		elif distance <= CHASE_RANGE:
			_move_toward(_player.global_position, move_speed)
		else:
			_wander(delta)
	else:
		_wander(delta)

	if is_on_floor() and is_on_wall() and Vector2(velocity.x, velocity.z).length() > 0.1:
		velocity.y = AUTO_JUMP_VELOCITY

	_visual.moving = Vector2(velocity.x, velocity.z).length() > 0.1
	move_and_slide()


func take_hit(damage: float, from_position: Vector3) -> void:
	hp -= damage
	# repelão pra dar leitura de acerto sem sistema de animação
	var away := global_position - from_position
	away.y = 0.0
	if away.length() > 0.01:
		velocity += away.normalized() * 4.0
	if hp <= 0.0:
		GameState.add_item("cristal", 1)
		get_tree().call_group("hud", "flash_message", "Vulto derrotado (+1 cristal).")
		queue_free()


func _wander(delta: float) -> void:
	_decision_timer -= delta
	if _decision_timer <= 0.0:
		_decision_timer = randf_range(2.0, 4.0)
		_wander_target = global_position + Vector3(randf_range(-6.0, 6.0), 0.0, randf_range(-6.0, 6.0))
	if global_position.distance_to(_wander_target) > 0.6:
		_move_toward(_wander_target, move_speed * 0.4)
	else:
		velocity.x = 0.0
		velocity.z = 0.0


func _move_toward(target: Vector3, speed: float) -> void:
	var to_target := target - global_position
	to_target.y = 0.0
	if to_target.length() < 0.05:
		return
	var direction := to_target.normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	look_at(global_position + direction, Vector3.UP)
