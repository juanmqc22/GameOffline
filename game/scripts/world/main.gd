extends Node3D
## Cena principal do MVP: mundo em blocos (Floresta Viva), jogador, as 3
## criaturas do elenco, HUD e controles touch. Ver docs/GDD.md.
## Responsável por assentar jogador e criaturas sobre o terreno gerado —
## o BlockWorld (filho, _ready antes deste) já existe quando isto roda.

@onready var _world: BlockWorld = $BlockWorld


func _ready() -> void:
	SaveManager.load_game()
	_place_on_ground($Player)
	$Player.set_spawn_point($Player.position)
	for creature in get_tree().get_nodes_in_group("creature"):
		_place_on_ground(creature)


func _place_on_ground(node: Node3D) -> void:
	node.position.y = _world.height_at(node.position) + 0.3


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		SaveManager.save_game()
