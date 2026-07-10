extends CharacterBody3D
## Player: movimento via joystick virtual (esquerda) + órbita de câmera via
## arraste do lado direito da tela. Toque curto no mundo (sem arrastar) faz
## raycast e, estilo Minecraft mobile: MINERA o bloco tocado, COLOCA o bloco
## selecionado na hotbar, ou ATACA o bicho tocado. O botão "Agir" continua
## sendo o gesto de cuidado (alimentar/aproximar/colher/beber) — GDD §9/§15.
##
## O corpo físico NÃO gira com o movimento — só o nó Visual gira. Se o corpo
## girasse, o CameraPivot (filho) giraria junto e a câmera rodaria sozinha.

@export var move_speed: float = 4.0
@export var camera_orbit_speed: float = 2.5
@export var interact_range: float = 3.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var visual: BlockyPlayerVisual = $Visual

const GRAVITY: float = 9.8
const AUTO_JUMP_VELOCITY: float = 5.2 # sobe degraus de 1 bloco, estilo auto-jump do MC mobile
const FALL_RESET_Y: float = -10.0
const REACH: float = 5.0 # alcance de minerar/colocar/atacar
const ATTACK_DAMAGE: float = 25.0
const TAP_MAX_DRAG: float = 16.0 # px — mais que isso é arraste de câmera, não toque
const TAP_MAX_SECONDS: float = 0.35

var _joystick: TouchJoystick = null
var _camera_yaw: float = 0.0
var _camera_touch_index: int = -1
var _last_touch_position: Vector2 = Vector2.ZERO
var _touch_start_position: Vector2 = Vector2.ZERO
var _touch_start_seconds: float = 0.0
var _touch_drag_distance: float = 0.0
var _pending_tap: Vector2 = Vector2.INF # processado no _physics_process (raycast)
var _spawn_point: Vector3 = Vector3.ZERO


func _ready() -> void:
	add_to_group("player")
	# a SpringArm não pode colidir com o próprio corpo do jogador
	$CameraPivot/SpringArm3D.add_excluded_object(get_rid())
	GameState.player_died.connect(_on_player_died)


func set_spawn_point(point: Vector3) -> void:
	_spawn_point = point


func _unhandled_input(event: InputEvent) -> void:
	var viewport_width := get_viewport().get_visible_rect().size.x

	if event is InputEventScreenTouch:
		if event.position.x > viewport_width * 0.5:
			if event.pressed and _camera_touch_index == -1:
				_camera_touch_index = event.index
				_last_touch_position = event.position
				_touch_start_position = event.position
				_touch_start_seconds = Time.get_ticks_msec() / 1000.0
				_touch_drag_distance = 0.0
			elif not event.pressed and event.index == _camera_touch_index:
				_camera_touch_index = -1
				var held := Time.get_ticks_msec() / 1000.0 - _touch_start_seconds
				if _touch_drag_distance < TAP_MAX_DRAG and held < TAP_MAX_SECONDS:
					_pending_tap = event.position
	elif event is InputEventScreenDrag and event.index == _camera_touch_index:
		var delta_x: float = event.position.x - _last_touch_position.x
		_touch_drag_distance += event.position.distance_to(_last_touch_position)
		_last_touch_position = event.position
		_camera_yaw -= delta_x * 0.01 * camera_orbit_speed


func _physics_process(delta: float) -> void:
	if global_position.y < FALL_RESET_Y:
		global_position = _spawn_point + Vector3.UP
		velocity = Vector3.ZERO

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	camera_pivot.rotation.y = _camera_yaw

	# o joystick é criado pelo TouchControls depois do _ready do player,
	# então a busca é preguiçosa aqui em vez de @onready
	if _joystick == null:
		_joystick = get_tree().get_first_node_in_group("move_joystick")

	var input_dir: Vector2 = _joystick.output if _joystick != null else Vector2.ZERO
	var forward := -camera_pivot.global_transform.basis.z
	var right := camera_pivot.global_transform.basis.x
	var move_dir := (right * input_dir.x + forward * -input_dir.y)
	move_dir.y = 0.0

	var is_moving := move_dir.length() > 0.01
	if is_moving:
		move_dir = move_dir.normalized()
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
		visual.rotation.y = lerp_angle(visual.rotation.y, atan2(-move_dir.x, -move_dir.z), 12.0 * delta)
		if is_on_floor() and is_on_wall():
			velocity.y = AUTO_JUMP_VELOCITY
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	visual.moving = is_moving and is_on_floor()
	move_and_slide()

	# raycast de toque fica pra física (espaço 3D travado fora daqui)
	if _pending_tap.is_finite():
		var tap := _pending_tap
		_pending_tap = Vector2.INF
		_handle_world_tap(tap)


## Toque curto no mundo: atacar bicho > colocar bloco (slot da hotbar
## selecionado) > minerar bloco.
func _handle_world_tap(screen_position: Vector2) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var from := camera.project_ray_origin(screen_position)
	var direction := camera.project_ray_normal(screen_position)
	var query := PhysicsRayQueryParameters3D.create(from, from + direction * 60.0)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	if global_position.distance_to(hit["position"]) > REACH:
		return # longe demais — silencioso, como no Minecraft

	var collider: Object = hit["collider"]
	if collider != null and collider.has_method("take_hit"):
		collider.take_hit(ATTACK_DAMAGE, global_position)
		return

	var world := get_tree().get_first_node_in_group("voxel_world") as VoxelWorld
	if world == null:
		return
	var hit_position: Vector3 = hit["position"]
	var hit_normal: Vector3 = hit["normal"]

	var hotbar := get_tree().get_first_node_in_group("hotbar")
	var selected: String = hotbar.selected_item() if hotbar != null else ""
	if selected != "":
		if GameState.item_count(selected) <= 0:
			_flash("Você não tem mais %s." % GameState.item_name(selected).to_lower())
			return
		var place_cell := Vector3i((hit_position + hit_normal * 0.5).floor())
		if _cell_overlaps_player(place_cell):
			return
		if world.try_place(place_cell, selected):
			GameState.remove_item(selected)
	else:
		var mine_cell := Vector3i((hit_position - hit_normal * 0.5).floor())
		var drop := world.mine_block(mine_cell)
		if drop != "":
			GameState.add_item(drop)


func _cell_overlaps_player(cell: Vector3i) -> bool:
	var center := Vector3(cell) + Vector3(0.5, 0.5, 0.5)
	return absf(center.x - global_position.x) < 0.9 \
		and absf(center.z - global_position.z) < 0.9 \
		and center.y > global_position.y - 0.6 \
		and center.y < global_position.y + 2.3


func _on_player_died() -> void:
	global_position = _spawn_point + Vector3.UP
	velocity = Vector3.ZERO
	GameState.revive_player()
	_flash("Você desmaiou e acordou no acampamento.")


## Botão "Agir" (TouchControls): a prioridade é criatura > coleta > água.
func try_interact() -> void:
	if _try_feed_or_approach_creature():
		return
	if _try_collect():
		return
	if _try_drink():
		return
	_flash("Nada por perto pra interagir.")


## Botão "Comer": consome a primeira comida disponível do inventário.
func try_eat() -> void:
	for food_id in GameState.FOOD_VALUES:
		if GameState.remove_item(food_id):
			GameState.feed_player(GameState.FOOD_VALUES[food_id])
			_flash("Você comeu: %s." % GameState.item_name(food_id))
			return
	_flash("Você não tem nada pra comer.")


func _try_feed_or_approach_creature() -> bool:
	var nearest: CreatureAI = null
	var best_distance := interact_range
	for node in get_tree().get_nodes_in_group("creature"):
		var creature := node as CreatureAI
		if creature == null or creature.data == null or creature.data.has_left:
			continue
		var distance := global_position.distance_to(creature.global_position)
		if distance < best_distance:
			best_distance = distance
			nearest = creature
	if nearest == null:
		return false

	# tenta alimentar, oferecendo a comida favorita primeiro se estiver na mochila
	var food_order: Array = []
	if nearest.data.favorite_food_id != "":
		food_order.append(nearest.data.favorite_food_id)
	for food_id in GameState.FOOD_VALUES:
		if not food_order.has(food_id):
			food_order.append(food_id)
	for food_id in food_order:
		if GameState.item_count(food_id) > 0:
			GameState.remove_item(food_id)
			nearest.feed(food_id)
			var reaction := " Adorou!" if food_id == nearest.data.favorite_food_id else ""
			_flash("%s comeu %s.%s (confiança %d)" % [
				nearest.data.display_name, GameState.item_name(food_id).to_lower(),
				reaction, int(nearest.data.trust)])
			return true

	# sem comida: aproximação calma (GDD seção 9), com cooldown por criatura
	if nearest.calm_approach():
		_flash("Você se aproxima com calma de %s. (confiança %d)" % [
			nearest.data.display_name, int(nearest.data.trust)])
	else:
		_flash("%s ainda está avaliando você. Dê um tempo." % nearest.data.display_name)
	return true


func _try_collect() -> bool:
	# props são acessados dinamicamente (Variant) — vêm de grupos, sem class_name
	for bush in get_tree().get_nodes_in_group("berry_bush"):
		if bush.has_berries and global_position.distance_to(bush.global_position) <= interact_range:
			var amount: int = bush.collect()
			GameState.add_item("baga_vermelha", amount)
			_flash("Você colheu %d bagas vermelhas." % amount)
			return true
	for mushroom in get_tree().get_nodes_in_group("mushroom"):
		if mushroom.is_available and global_position.distance_to(mushroom.global_position) <= interact_range:
			mushroom.collect()
			GameState.add_item("cogumelo_azul", 1)
			_flash("Você colheu um cogumelo azul.")
			return true
	return false


func _try_drink() -> bool:
	var world := get_tree().get_first_node_in_group("voxel_world") as VoxelWorld
	if world == null:
		return false
	if world.nearest_water_distance(global_position) <= 2.5:
		GameState.hydrate_player(35.0)
		_flash("Você bebeu água fresca.")
		return true
	return false


func _flash(text: String) -> void:
	get_tree().call_group("hud", "flash_message", text)
