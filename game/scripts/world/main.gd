extends Node3D
## Cena principal do MVP: 1 bioma (placeholder), 1 criatura, jogador, HUD, controles touch.
## Ver docs/GDD.md para o desenho completo. Isto é o esqueleto mínimo jogável.

func _ready() -> void:
	SaveManager.load_game()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
		SaveManager.save_game()
