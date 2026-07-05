extends CanvasLayer
## HUD minimalista: três barras discretas (fome, sede, sono). Ver docs/GDD.md seção 15.

var _hunger_bar: ProgressBar
var _thirst_bar: ProgressBar
var _sleep_bar: ProgressBar


func _ready() -> void:
	var container := VBoxContainer.new()
	container.position = Vector2(24, 24)
	container.custom_minimum_size = Vector2(160, 0)
	add_child(container)

	_hunger_bar = _make_bar("Fome")
	_thirst_bar = _make_bar("Sede")
	_sleep_bar = _make_bar("Sono")
	container.add_child(_hunger_bar)
	container.add_child(_thirst_bar)
	container.add_child(_sleep_bar)

	_hunger_bar.value = GameState.player_hunger
	_thirst_bar.value = GameState.player_thirst
	_sleep_bar.value = GameState.player_sleep

	GameState.hunger_changed.connect(func(v): _hunger_bar.value = v)
	GameState.thirst_changed.connect(func(v): _thirst_bar.value = v)
	GameState.sleep_changed.connect(func(v): _sleep_bar.value = v)


func _make_bar(label_text: String) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.custom_minimum_size = Vector2(160, 20)
	bar.show_percentage = false
	var label := Label.new()
	label.text = label_text
	bar.add_child(label)
	return bar
