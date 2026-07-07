extends CanvasLayer
## Constrói os controles touch em código — sem depender de arte ainda.
## Joystick esquerdo para movimento; lado direito da tela reservado ao arraste
## de câmera (ver player_controller.gd). Botões: "Agir" (interação contextual)
## e "Comer" (consome comida do inventário) — o menu radial do GDD seção 15
## vem depois, isto é o mínimo jogável.

const JOYSTICK_SIZE: float = 220.0
const MARGIN: float = 40.0


func _ready() -> void:
	var viewport_size := get_viewport().get_visible_rect().size

	var joystick := VirtualJoystick.new()
	joystick.name = "MoveJoystick"
	joystick.size = Vector2(JOYSTICK_SIZE, JOYSTICK_SIZE)
	joystick.position = Vector2(MARGIN, viewport_size.y - JOYSTICK_SIZE - MARGIN)
	joystick.mouse_filter = Control.MOUSE_FILTER_STOP
	joystick.add_to_group("move_joystick")
	add_child(joystick)

	var action_button := _make_button("Agir", Vector2(140, 140),
		Vector2(viewport_size.x - 140 - MARGIN, viewport_size.y - 140 - MARGIN))
	var eat_button := _make_button("Comer", Vector2(110, 110),
		Vector2(viewport_size.x - 110 - MARGIN, viewport_size.y - 140 - MARGIN - 110 - 24))

	var hotbar := Hotbar.new()
	# largura ~5×105 + 4×10 = 565; centrada, acima da borda inferior
	hotbar.position = Vector2(viewport_size.x * 0.5 - 282, viewport_size.y - 105 - 16)
	add_child(hotbar)

	var player := get_tree().get_first_node_in_group("player")
	if player != null:
		action_button.pressed.connect(Callable(player, "try_interact"))
		eat_button.pressed.connect(Callable(player, "try_eat"))


func _make_button(text: String, button_size: Vector2, button_position: Vector2) -> Button:
	var button := Button.new()
	button.text = text
	button.size = button_size
	button.position = button_position
	button.add_theme_font_size_override("font_size", 30)
	add_child(button)
	return button
