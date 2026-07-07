extends Node
## Autoload: GameState
## Estado global da sessão em memória. Não persiste sozinho — SaveManager lê/escreve isto.

signal hunger_changed(value: float)
signal thirst_changed(value: float)
signal sleep_changed(value: float)
signal inventory_changed

const MAX_STAT: float = 100.0
const STAT_DRAIN_PER_HOUR: float = 4.0 # ritmo de fome/sede/sono ao longo de um dia in-game

## Itens comestíveis e quanto restauram de fome (do jogador). Alimentar
## criaturas usa os mesmos ids — a favorita de cada uma está no CreatureData.
const FOOD_VALUES := {"baga_vermelha": 18.0, "cogumelo_azul": 28.0}
const ITEM_NAMES := {"baga_vermelha": "Baga vermelha", "cogumelo_azul": "Cogumelo azul"}

var player_hunger: float = MAX_STAT
var player_thirst: float = MAX_STAT
var player_sleep: float = MAX_STAT

var day_count: int = 1
var bonded_creature_ids: Array[String] = []
var inventory: Dictionary = {} # item_id (String) -> quantidade (int)


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


func item_name(item_id: String) -> String:
	return ITEM_NAMES.get(item_id, item_id)


func item_count(item_id: String) -> int:
	return int(inventory.get(item_id, 0))


func add_item(item_id: String, amount: int = 1) -> void:
	inventory[item_id] = item_count(item_id) + amount
	inventory_changed.emit()


func remove_item(item_id: String, amount: int = 1) -> bool:
	if item_count(item_id) < amount:
		return false
	inventory[item_id] = item_count(item_id) - amount
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	inventory_changed.emit()
	return true


## Reemite tudo — usado pelo SaveManager após carregar, pra HUD refletir o save.
func emit_state_signals() -> void:
	hunger_changed.emit(player_hunger)
	thirst_changed.emit(player_thirst)
	sleep_changed.emit(player_sleep)
	inventory_changed.emit()
