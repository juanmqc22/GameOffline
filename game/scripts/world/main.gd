extends Node3D
## Cena principal do MVP: mundo voxel editável, jogador, as 3 criaturas do
## elenco, fauna, vultos noturnos, HUD e controles touch. Ver docs/GDD.md.
## Ordem importa: o VoxelWorld (filho, _ready antes deste) já gerou o terreno;
## aqui carregamos o save, reaplicamos as edições de mundo e só então
## assentamos jogador e criaturas sobre o terreno final.

@onready var _world: VoxelWorld = $VoxelWorld


func _ready() -> void:
	SaveManager.load_game()
	_world.apply_saved_edits()
	_place_on_ground($Player)
	$Player.set_spawn_point($Player.position)
	for creature in get_tree().get_nodes_in_group("creature"):
		_place_on_ground(creature)


func _place_on_ground(node: Node3D) -> void:
	node.position.y = _world.height_at(node.position) + 0.3


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		SaveManager.save_game()
