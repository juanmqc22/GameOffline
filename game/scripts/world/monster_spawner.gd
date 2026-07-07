extends Node
## Spawner de vultos: a cada anoitecer (TimeManager.night_started) cria uma
## leva ao redor do jogador, em terra firme e longe o bastante pra dar tempo
## de reagir. Os vultos se removem sozinhos ao amanhecer (ver monster.gd).

const MONSTERS_PER_NIGHT := 5
const MIN_DISTANCE := 15.0
const MAX_DISTANCE := 28.0

const MonsterScript := preload("res://scripts/world/monster.gd")


func _ready() -> void:
	TimeManager.night_started.connect(_on_night_started)


func _on_night_started() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node3D
	var world := get_tree().get_first_node_in_group("voxel_world") as VoxelWorld
	if player == null or world == null:
		return
	var spawned := 0
	var attempts := 0
	while spawned < MONSTERS_PER_NIGHT and attempts < 60:
		attempts += 1
		var angle := randf_range(0.0, TAU)
		var distance := randf_range(MIN_DISTANCE, MAX_DISTANCE)
		var position_2d := Vector2(player.global_position.x, player.global_position.z) \
			+ Vector2(cos(angle), sin(angle)) * distance
		var ground := world.height_at(Vector3(position_2d.x, 0.0, position_2d.y))
		if ground <= VoxelWorld.WATER_LEVEL: # não nasce na água nem fora da ilha
			continue
		var monster: CharacterBody3D = MonsterScript.new()
		monster.position = Vector3(position_2d.x, ground + 0.5, position_2d.y)
		add_child(monster)
		spawned += 1
	if spawned > 0:
		get_tree().call_group("hud", "flash_message", "A noite chegou... vultos rondam a ilha.")
