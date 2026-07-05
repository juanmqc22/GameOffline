extends Node
## Autoload: GameState
## Estado global da sessão em memória. Não persiste sozinho — SaveManager lê/escreve isto.

signal hunger_changed(value: float)
signal thirst_changed(value: float)
signal sleep_changed(value: float)

const MAX_STAT: float = 100.0
const STAT_DRAIN_PER_HOUR: float = 4.0 # ritmo de fome/sede/sono ao longo de um dia in-game

var player_hunger: float = MAX_STAT
var player_thirst: float = MAX_STAT
var player_sleep: float = MAX_STAT

var day_count: int = 1
var bonded_creature_ids: Array[String] = []


func drain_survival_stats(game_hours_elapsed: float) -> void:
	var drain := STAT_DRAIN_PER_HOUR * game_hours_elapsed
	player_hunger = clampf(player_hunger - drain, 0.0, MAX_STAT)
	player_thirst = clampf(player_thirst - drain * 1.2, 0.0, MAX_STAT)
	player_sleep = clampf(player_sleep - drain * 0.6, 0.0, MAX_STAT)
	hunger_changed.emit(player_hunger)
	thirst_changed.emit(player_thirst)
	sleep_changed.emit(player_sleep)


func feed_player(amount: float) -> void:
	player_hunger = clampf(player_hunger + amount, 0.0, MAX_STAT)
	hunger_changed.emit(player_hunger)


func hydrate_player(amount: float) -> void:
	player_thirst = clampf(player_thirst + amount, 0.0, MAX_STAT)
	thirst_changed.emit(player_thirst)


func rest_player(amount: float) -> void:
	player_sleep = clampf(player_sleep + amount, 0.0, MAX_STAT)
	sleep_changed.emit(player_sleep)


func mark_creature_bonded(creature_id: String) -> void:
	if not bonded_creature_ids.has(creature_id):
		bonded_creature_ids.append(creature_id)
