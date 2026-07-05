extends CanvasLayer
## Constrói os controles touch em código — sem depender de arte ainda.
## Joystick esquerdo para movimento (ver player_controller.gd).
## O lado direito da tela é reservado para o arraste de câmera (ver player_controller.gd).

const JOYSTICK_SIZE: float = 220.0
const MARGIN: float = 40.0


func _ready() -> void:
	var joystick := VirtualJoystick.new()
	joystick.name = "MoveJoystick"
	joystick.size = Vector2(JOYSTICK_SIZE, JOYSTICK_SIZE)
	joystick.position = Vector2(MARGIN, get_viewport().get_visible_rect().size.y - JOYSTICK_SIZE - MARGIN)
	joystick.mouse_filter = Control.MOUSE_FILTER_STOP
	joystick.add_to_group("move_joystick")
	add_child(joystick)

	var action_button := Button.new()
	action_button.name = "ActionButton"
	action_button.text = "Agir"
	action_button.size = Vector2(120, 120)
	var viewport_size := get_viewport().get_visible_rect().size
	action_button.position = Vector2(viewport_size.x - 120 - MARGIN, viewport_size.y - 120 - MARGIN)
	add_child(action_button)
