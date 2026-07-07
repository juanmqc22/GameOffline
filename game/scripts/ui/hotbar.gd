extends HBoxContainer
class_name Hotbar
## Hotbar de blocos colocáveis (embaixo, centro da tela). Comportamento
## estilo Minecraft mobile: com um slot selecionado, tocar no mundo COLOCA
## aquele bloco; sem slot selecionado, tocar no mundo MINERA/ataca.
## Tocar o slot já selecionado desmarca. Construída em código, como toda a UI.

const SLOT_ITEMS: Array[String] = ["terra", "pedra", "areia", "tronco", "neve"]
const SELECTED_TINT := Color(1.0, 0.95, 0.5)

var _selected := ""
var _buttons := {} # item_id -> Button


func _ready() -> void:
	add_to_group("hotbar")
	add_theme_constant_override("separation", 10)
	for item_id in SLOT_ITEMS:
		var button := Button.new()
		button.custom_minimum_size = Vector2(105, 105)
		button.add_theme_font_size_override("font_size", 20)
		button.pressed.connect(_on_slot_pressed.bind(item_id))
		add_child(button)
		_buttons[item_id] = button
	GameState.inventory_changed.connect(_refresh)
	_refresh()


## Consultada pelo player_controller na hora do toque no mundo.
func selected_item() -> String:
	return _selected


func _on_slot_pressed(item_id: String) -> void:
	_selected = "" if _selected == item_id else item_id
	_refresh()


func _refresh() -> void:
	for item_id in _buttons:
		var button: Button = _buttons[item_id]
		button.text = "%s\n×%d" % [GameState.item_name(item_id), GameState.item_count(item_id)]
		button.modulate = SELECTED_TINT if item_id == _selected else Color.WHITE
