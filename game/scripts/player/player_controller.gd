extends CharacterBody3D
## Player: movimento via joystick virtual (esquerda) + órbita de câmera
## via arraste do lado direito da tela. Ver docs/GDD.md seção 15.

@export var move_speed: float = 4.0
@export var camera_orbit_speed: float = 2.5

@onready var camera_pivot: Node3D = $CameraPivot
@onready var joystick: VirtualJoystick = get_tree().get_first_node_in_group("move_joystick")

const GRAVITY: float = 9.8

var _camera_yaw: float = 0.0
var _camera_touch_index: int = -1
var _last_touch_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	add_to_group("player")


func _unhandled_input(event: InputEvent) -> void:
	var viewport_width := get_viewport().get_visible_rect().size.x

	if event is InputEventScreenTouch:
		if event.position.x > viewport_width * 0.5:
			if event.pressed and _camera_touch_index == -1:
				_camera_touch_index = event.index
				_last_touch_position = event.position
			elif not event.pressed and event.index == _camera_touch_index:
				_camera_touch_index = -1
	elif event is InputEventScreenDrag and event.index == _camera_touch_index:
		var delta_x := event.position.x - _last_touch_position.x
		_last_touch_position = event.position
		_camera_yaw -= delta_x * 0.01 * camera_orbit_speed


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	camera_pivot.rotation.y = _camera_yaw

	var input_dir: Vector2 = joystick.output if joystick != null else Vector2.ZERO
	var forward := -camera_pivot.global_transform.basis.z
	var right := camera_pivot.global_transform.basis.x
	var move_dir := (right * input_dir.x + forward * -input_dir.y)
	move_dir.y = 0.0

	if move_dir.length() > 0.01:
		move_dir = move_dir.normalized()
		velocity.x = move_dir.x * move_speed
		velocity.z = move_dir.z * move_speed
		look_at(global_position + move_dir, Vector3.UP)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
