extends Node
## Autoload: SaveManager
## Salvamento local em user:// — sem servidor, sem internet, 100% offline.

const SAVE_PATH: String = "user://saves/slot_1.json"


func save_game() -> void:
	var creatures_out: Array = []
	for creature in CreatureRegistry.all_creatures():
		creatures_out.append({
			"creature_id": creature.creature_id,
			"trust": creature.trust,
			"hunger": creature.hunger,
			"fatigue": creature.fatigue,
			"is_bonded": creature.is_bonded,
			"is_injured": creature.is_injured,
			"has_left": creature.has_left,
			"memory_flags": creature.memory_flags,
		})

	var save_data := {
		"day_count": GameState.day_count,
		"player_hunger": GameState.player_hunger,
		"player_thirst": GameState.player_thirst,
		"player_sleep": GameState.player_sleep,
		"player_health": GameState.player_health,
		"bonded_creature_ids": GameState.bonded_creature_ids,
		"inventory": GameState.inventory,
		"world_edits": GameState.world_edits,
		"creatures": creatures_out,
	}

	DirAccess.make_dir_recursive_absolute(SAVE_PATH.get_base_dir())
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: falha ao abrir arquivo de save: %s" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var content := file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(content)
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		push_error("SaveManager: save corrompido ou em formato inesperado")
		return false

	GameState.day_count = parsed.get("day_count", 1)
	GameState.player_hunger = parsed.get("player_hunger", 100.0)
	GameState.player_thirst = parsed.get("player_thirst", 100.0)
	GameState.player_sleep = parsed.get("player_sleep", 100.0)
	var bonded_ids: Array = parsed.get("bonded_creature_ids", [])
	GameState.bonded_creature_ids.assign(bonded_ids)

	GameState.player_health = parsed.get("player_health", 100.0)

	GameState.inventory.clear()
	var saved_inventory: Dictionary = parsed.get("inventory", {})
	for item_id in saved_inventory:
		GameState.inventory[item_id] = int(saved_inventory[item_id]) # JSON devolve floats

	GameState.world_edits.clear()
	var saved_edits: Dictionary = parsed.get("world_edits", {})
	for key in saved_edits:
		GameState.world_edits[key] = int(saved_edits[key])

	for entry in parsed.get("creatures", []):
		var creature := CreatureRegistry.get_creature(entry.get("creature_id", ""))
		if creature == null:
			continue
		creature.trust = entry.get("trust", 0.0)
		creature.hunger = entry.get("hunger", 100.0)
		creature.fatigue = entry.get("fatigue", 0.0)
		creature.is_bonded = entry.get("is_bonded", false)
		creature.is_injured = entry.get("is_injured", false)
		creature.has_left = entry.get("has_left", false)
		var flags: Array[String] = []
		flags.assign(entry.get("memory_flags", []))
		creature.memory_flags = flags

	GameState.emit_state_signals()
	return true
