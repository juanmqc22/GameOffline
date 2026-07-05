extends Node
## Autoload: CreatureRegistry
## Mantém a lista de CreatureData em memória durante a sessão, indexada por id.
## SaveManager lê isto para persistir e escreve de volta ao carregar.

var _creatures_by_id: Dictionary = {} # String -> CreatureData


func register(data: CreatureData) -> void:
	_creatures_by_id[data.creature_id] = data


func get_creature(creature_id: String) -> CreatureData:
	return _creatures_by_id.get(creature_id, null)


func all_creatures() -> Array:
	return _creatures_by_id.values()


func bonded_creatures() -> Array:
	return all_creatures().filter(func(c: CreatureData): return c.is_bonded)
