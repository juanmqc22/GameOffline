extends CanvasLayer
## HUD minimalista: barras de fome/sede/sono, relógio do dia, inventário e
## mensagens contextuais das interações. Ver docs/GDD.md seção 15.
## Construído em código, como o resto da UI (ver CLAUDE.md).

var _health_bar: ProgressBar
var _hunger_bar: ProgressBar
var _thirst_bar: ProgressBar
var _sleep_bar: ProgressBar
var _clock_label: Label
var _inventory_label: Label
var _message_label: Label
var _message_tween: Tween


func _ready() -> void:
	add_to_group("hud")
	var viewport_size := get_viewport().get_visible_rect().size

	var bars := VBoxContainer.new()
	bars.position = Vector2(24, 24)
	bars.custom_minimum_size = Vector2(240, 0)
	add_child(bars)

	_health_bar = _make_bar("Vida")
	_hunger_bar = _make_bar("Fome")
	_thirst_bar = _make_bar("Sede")
	_sleep_bar = _make_bar("Sono")
	bars.add_child(_health_bar)
	bars.add_child(_hunger_bar)
	bars.add_child(_thirst_bar)
	bars.add_child(_sleep_bar)

	_health_bar.value = GameState.player_health
	_hunger_bar.value = GameState.player_hunger
	_thirst_bar.value = GameState.player_thirst
	_sleep_bar.value = GameState.player_sleep

	_clock_label = Label.new()
	_clock_label.position = Vector2(viewport_size.x - 300, 24)
	_clock_label.custom_minimum_size = Vector2(276, 0)
	_clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_clock_label.add_theme_font_size_override("font_size", 26)
	add_child(_clock_label)

	_inventory_label = Label.new()
	_inventory_label.position = Vector2(viewport_size.x - 420, 62)
	_inventory_label.custom_minimum_size = Vector2(396, 0)
	_inventory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_inventory_label.add_theme_font_size_override("font_size", 22)
	add_child(_inventory_label)

	_message_label = Label.new()
	_message_label.position = Vector2(viewport_size.x * 0.5 - 340, viewport_size.y * 0.22)
	_message_label.custom_minimum_size = Vector2(680, 0)
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_message_label.add_theme_font_size_override("font_size", 28)
	_message_label.modulate.a = 0.0
	add_child(_message_label)

	GameState.health_changed.connect(func(v): _health_bar.value = v)
	GameState.hunger_changed.connect(func(v): _hunger_bar.value = v)
	GameState.thirst_changed.connect(func(v): _thirst_bar.value = v)
	GameState.sleep_changed.connect(func(v): _sleep_bar.value = v)
	GameState.inventory_changed.connect(_refresh_inventory)
	_refresh_inventory()


func _process(_delta: float) -> void:
	var hour: float = TimeManager.game_hour
	_clock_label.text = "Dia %d — %02d:%02d" % [
		GameState.day_count, floori(hour), int(fmod(hour, 1.0) * 60.0)]


## Mensagem contextual curta ("Você colheu 3 bagas...") que some sozinha.
## Chamada via call_group("hud", "flash_message", texto).
func flash_message(text: String) -> void:
	_message_label.text = text
	_message_label.modulate.a = 1.0
	if _message_tween != null:
		_message_tween.kill()
	_message_tween = create_tween()
	_message_tween.tween_interval(1.6)
	_message_tween.tween_property(_message_label, "modulate:a", 0.0, 0.9)


func _refresh_inventory() -> void:
	var parts: Array[String] = []
	for item_id in GameState.ITEM_NAMES:
		var count := GameState.item_count(item_id)
		if count > 0:
			parts.append("%s: %d" % [GameState.item_name(item_id), count])
	_inventory_label.text = " | ".join(parts)


func _make_bar(label_text: String) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.custom_minimum_size = Vector2(240, 26)
	bar.show_percentage = false
	var label := Label.new()
	label.text = label_text
	label.add_theme_font_size_override("font_size", 18)
	bar.add_child(label)
	return bar
