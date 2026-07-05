extends Node
## Autoload: TimeManager
## Ciclo dia/noite. 1 dia in-game = DAY_LENGTH_SECONDS segundos reais.

signal hour_passed(game_hour: float)
signal day_started(day_number: int)
signal night_started()

const DAY_LENGTH_SECONDS: float = 20.0 * 60.0 # 20 minutos reais = 1 dia in-game (ajustável)
const HOURS_PER_DAY: float = 24.0

var game_hour: float = 8.0 # começa de manhã
var _is_night: bool = false


func _process(delta: float) -> void:
	var hours_per_second := HOURS_PER_DAY / DAY_LENGTH_SECONDS
	var previous_hour := game_hour
	game_hour += delta * hours_per_second

	if game_hour >= HOURS_PER_DAY:
		game_hour -= HOURS_PER_DAY
		GameState.day_count += 1
		day_started.emit(GameState.day_count)

	if floori(game_hour) != floori(previous_hour):
		hour_passed.emit(game_hour)
		GameState.drain_survival_stats(1.0)

	var is_night_now := game_hour >= 20.0 or game_hour < 6.0
	if is_night_now != _is_night:
		_is_night = is_night_now
		if _is_night:
			night_started.emit()


func is_night() -> bool:
	return _is_night
