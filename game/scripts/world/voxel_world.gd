extends Node3D
class_name VoxelWorld
## Mundo voxel EDITÁVEL estilo Minecraft (GDD seções 6, 7, 13 e 16).
## Substitui o BlockWorld de malha única: agora os blocos vivem num Dictionary
## (Vector3i -> id) e a ilha é dividida em chunks de 16×16 colunas, cada um com
## a própria malha + colisão trimesh — minerar/colocar um bloco remalha só o
## chunk afetado. A geração usa seed fixa; as EDIÇÕES do jogador são o diff
## persistido no save (GameState.world_edits), o resto é sempre regenerável.
##
## Biomas do MVP (por ruído + altura): Campo, Floresta, Deserto e Montanha.

# ids de bloco (0 = ar)
const AIR := 0
const GRASS := 1
const DIRT := 2
const STONE := 3
const SAND := 4
const WOOD := 5
const LEAVES := 6
const SNOW := 7
const BEDROCK := 8
const COAL_ORE := 9
const CRYSTAL_ORE := 10

enum Biome { CAMPO, FLORESTA, DESERTO, MONTANHA }

const SIZE := 64
const HALF := SIZE / 2
const CHUNK_SIZE := 16
const MAX_Y := 40 # teto de construção
const WATER_LEVEL := 4
const PLATEAU_RADIUS := 7.0
const PLATEAU_HEIGHT := 5
const WORLD_SEED := 20260707

const BLOCK_COLORS := {
	DIRT: Color(0.48, 0.34, 0.22),
	STONE: Color(0.52, 0.52, 0.54),
	SAND: Color(0.83, 0.77, 0.55),
	WOOD: Color(0.42, 0.29, 0.16),
	LEAVES: Color(0.22, 0.48, 0.19),
	SNOW: Color(0.92, 0.94, 0.97),
	BEDROCK: Color(0.2, 0.2, 0.22),
	COAL_ORE: Color(0.33, 0.33, 0.36),
	CRYSTAL_ORE: Color(0.45, 0.65, 0.85),
}
const GRASS_COLORS := {
	Biome.CAMPO: Color(0.45, 0.62, 0.25),
	Biome.FLORESTA: Color(0.3, 0.55, 0.22),
	Biome.DESERTO: Color(0.45, 0.62, 0.25), # não ocorre, deserto usa areia
	Biome.MONTANHA: Color(0.38, 0.55, 0.3),
}
const COLOR_WATER := Color(0.2, 0.42, 0.75, 0.6)

## O que cada bloco vira no inventário ao ser minerado ("" = não deixa nada).
const BLOCK_DROPS := {
	GRASS: "terra", DIRT: "terra", STONE: "pedra", SAND: "areia",
	WOOD: "tronco", LEAVES: "", SNOW: "neve",
	COAL_ORE: "carvao", CRYSTAL_ORE: "cristal",
}
## O que cada item do inventário vira ao ser colocado no mundo.
const ITEM_BLOCKS := {
	"terra": DIRT, "pedra": STONE, "areia": SAND, "tronco": WOOD, "neve": SNOW,
}

## Sombreamento por face — o "cheiro" de Minecraft: topo claro, laterais escuras.
## Cada face: normal + 4 cantos em ordem horária vista de fora (winding do Godot).
const FACES := [
	{"n": Vector3i(0, 1, 0), "s": 1.0, "c": [Vector3(0, 1, 0), Vector3(1, 1, 0), Vector3(1, 1, 1), Vector3(0, 1, 1)]},
	{"n": Vector3i(0, -1, 0), "s": 0.5, "c": [Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 0, 0), Vector3(0, 0, 0)]},
	{"n": Vector3i(1, 0, 0), "s": 0.8, "c": [Vector3(1, 0, 0), Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(1, 1, 0)]},
	{"n": Vector3i(-1, 0, 0), "s": 0.8, "c": [Vector3(0, 0, 1), Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(0, 1, 1)]},
	{"n": Vector3i(0, 0, 1), "s": 0.7, "c": [Vector3(1, 0, 1), Vector3(0, 0, 1), Vector3(0, 1, 1), Vector3(1, 1, 1)]},
	{"n": Vector3i(0, 0, -1), "s": 0.7, "c": [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(0, 1, 0)]},
]

const BerryBushScript := preload("res://scripts/world/berry_bush.gd")
const MushroomScript := preload("res://scripts/world/mushroom.gd")
const AnimalScript := preload("res://scripts/world/animal.gd")

## Fauna comum por bioma (caça — GDD seção 10). As criaturas ESPECIAIS do
## elenco (Vix, Brum, Lume) são outra coisa: .tres + CreatureAI + vínculo.
const ANIMAL_SPECIES := [
	{"species": "capivara", "biomes": [Biome.CAMPO, Biome.FLORESTA], "count": 6,
		"body": Color(0.52, 0.36, 0.2), "accent": Color(0.36, 0.25, 0.14),
		"hp": 40.0, "meat": 2, "speed": 2.0, "scale": 1.15},
	{"species": "cabra", "biomes": [Biome.MONTANHA], "count": 4,
		"body": Color(0.85, 0.83, 0.78), "accent": Color(0.4, 0.38, 0.35),
		"hp": 30.0, "meat": 1, "speed": 2.6, "scale": 1.0},
	{"species": "lagarto", "biomes": [Biome.DESERTO], "count": 4,
		"body": Color(0.55, 0.6, 0.3), "accent": Color(0.75, 0.65, 0.4),
		"hp": 20.0, "meat": 1, "speed": 3.2, "scale": 0.7},
]

var _blocks := {} # Vector3i -> id
var _biomes := PackedByteArray() # bioma por coluna (definido na geração)
var _initial_heights := PackedInt32Array() # altura da geração (spawn de props/bichos)
var _water_cells: Array[Vector3] = []
var _blocked_columns := {} # Vector2i -> true (árvore/arbusto já ocupa)
var _chunks := {} # Vector2i -> {"mesh": MeshInstance3D, "shape": CollisionShape3D}
var _rng := RandomNumberGenerator.new()
var _block_material := StandardMaterial3D.new()


func _ready() -> void:
	add_to_group("voxel_world")
	_rng.seed = WORLD_SEED
	_block_material.vertex_color_use_as_albedo = true
	_block_material.roughness = 1.0
	_generate_terrain()
	_plant_trees()
	_create_chunk_nodes()
	for chunk_key in _chunks:
		_rebuild_chunk(chunk_key)
	_build_water_mesh()
	_scatter_props()
	_spawn_animals()


## ------------------------------------------------------------------ consulta

func get_block(cell: Vector3i) -> int:
	return _blocks.get(cell, AIR)


## Altura do topo do terreno (dinâmica — considera blocos minerados/colocados).
func height_at(world_pos: Vector3) -> float:
	var x := int(floorf(world_pos.x))
	var z := int(floorf(world_pos.z))
	for y in range(MAX_Y - 1, -1, -1):
		if _blocks.has(Vector3i(x, y, z)):
			return float(y + 1)
	return 0.0


func biome_at(world_x: int, world_z: int) -> int:
	var gx := world_x + HALF
	var gz := world_z + HALF
	if gx < 0 or gz < 0 or gx >= SIZE or gz >= SIZE:
		return Biome.CAMPO
	return _biomes[gx * SIZE + gz]


func nearest_water_distance(world_pos: Vector3) -> float:
	var best := INF
	for cell in _water_cells:
		best = minf(best, cell.distance_to(world_pos))
	return best


## ------------------------------------------------------------------- edição

## Minera o bloco e devolve o item que ele deixa ("" se nada foi minerado ou
## se o bloco não deixa item, como folhas). Rocha-mãe é inquebrável.
func mine_block(cell: Vector3i) -> String:
	var id := get_block(cell)
	if id == AIR or id == BEDROCK:
		return ""
	set_block(cell, AIR)
	return BLOCK_DROPS.get(id, "")


func try_place(cell: Vector3i, item_id: String) -> bool:
	if not ITEM_BLOCKS.has(item_id):
		return false
	if _blocks.has(cell):
		return false
	if not _in_bounds(cell):
		return false
	set_block(cell, ITEM_BLOCKS[item_id])
	return true


func set_block(cell: Vector3i, id: int, record: bool = true) -> void:
	if not _in_bounds(cell):
		return
	if id == AIR:
		_blocks.erase(cell)
	else:
		_blocks[cell] = id
	if record:
		GameState.world_edits["%d,%d,%d" % [cell.x, cell.y, cell.z]] = id
	for chunk_key in _chunks_touching(cell):
		_rebuild_chunk(chunk_key)


## Reaplica o diff salvo (chamado pelo Main depois do SaveManager.load_game,
## porque este nó fica pronto antes do load acontecer).
func apply_saved_edits() -> void:
	if GameState.world_edits.is_empty():
		return
	var dirty := {}
	for key in GameState.world_edits:
		var parts: PackedStringArray = String(key).split(",")
		if parts.size() != 3:
			continue
		var cell := Vector3i(int(parts[0]), int(parts[1]), int(parts[2]))
		if not _in_bounds(cell):
			continue
		var id := int(GameState.world_edits[key])
		if id == AIR:
			_blocks.erase(cell)
		else:
			_blocks[cell] = id
		for chunk_key in _chunks_touching(cell):
			dirty[chunk_key] = true
	for chunk_key in dirty:
		_rebuild_chunk(chunk_key)


func _in_bounds(cell: Vector3i) -> bool:
	return cell.x >= -HALF and cell.x < HALF \
		and cell.z >= -HALF and cell.z < HALF \
		and cell.y >= 1 and cell.y < MAX_Y # y=0 é rocha-mãe, intocável


## ------------------------------------------------------------------- geração

func _generate_terrain() -> void:
	var height_noise := FastNoiseLite.new()
	height_noise.seed = WORLD_SEED
	height_noise.frequency = 0.06
	var mountain_noise := FastNoiseLite.new()
	mountain_noise.seed = WORLD_SEED + 1
	mountain_noise.frequency = 0.035
	var biome_noise := FastNoiseLite.new()
	biome_noise.seed = WORLD_SEED + 2
	biome_noise.frequency = 0.02

	_biomes.resize(SIZE * SIZE)
	_initial_heights.resize(SIZE * SIZE)
	var center := Vector2(SIZE / 2.0, SIZE / 2.0)

	for gx in SIZE:
		for gz in SIZE:
			var base := height_noise.get_noise_2d(float(gx), float(gz)) * 0.5 + 0.5
			var h := 3 + int(roundf(base * 6.0)) # 3..9
			var mountain := mountain_noise.get_noise_2d(float(gx), float(gz)) * 0.5 + 0.5
			if mountain > 0.62:
				h += int((mountain - 0.62) * 26.0) # até ~+9
			h = clampi(h, 2, 15)

			var biome_value := biome_noise.get_noise_2d(float(gx), float(gz))
			var biome := Biome.CAMPO
			if biome_value < -0.28:
				biome = Biome.DESERTO
			elif biome_value > 0.1:
				biome = Biome.FLORESTA

			var dist := Vector2(gx + 0.5, gz + 0.5).distance_to(center)
			if dist <= PLATEAU_RADIUS:
				h = PLATEAU_HEIGHT
				biome = Biome.CAMPO
			elif dist <= PLATEAU_RADIUS + 3.0:
				h = clampi(h, PLATEAU_HEIGHT - 1, PLATEAU_HEIGHT + 1)

			if h >= 12:
				biome = Biome.MONTANHA

			_biomes[gx * SIZE + gz] = biome
			_initial_heights[gx * SIZE + gz] = h
			_fill_column(gx - HALF, gz - HALF, h, biome)

			if h < WATER_LEVEL:
				_water_cells.append(Vector3(gx - HALF + 0.5, WATER_LEVEL - 0.15, gz - HALF + 0.5))


func _fill_column(x: int, z: int, h: int, biome: int) -> void:
	var sandy := biome == Biome.DESERTO or h <= WATER_LEVEL # deserto e praias/fundo de lago
	for y in h:
		var cell := Vector3i(x, y, z)
		var id := STONE
		if y == 0:
			id = BEDROCK
		elif sandy and y >= h - 3:
			id = SAND
		elif biome == Biome.MONTANHA and y == h - 1:
			id = SNOW if h >= 13 else STONE
		elif y == h - 1:
			id = GRASS
		elif y >= h - 4:
			id = DIRT
		if id == STONE:
			# minérios escondidos na pedra: recompensa de cavar fundo
			if _rng.randf() < 0.05:
				id = COAL_ORE
			elif y <= 3 and _rng.randf() < 0.03:
				id = CRYSTAL_ORE
		_blocks[cell] = id


func _plant_trees() -> void:
	var center := Vector2(SIZE / 2.0, SIZE / 2.0)
	for gx in range(2, SIZE - 2):
		for gz in range(2, SIZE - 2):
			var biome := _biomes[gx * SIZE + gz]
			var chance := 0.0
			if biome == Biome.FLORESTA:
				chance = 1.0 / 16.0
			elif biome == Biome.CAMPO:
				chance = 1.0 / 70.0
			if chance <= 0.0 or _rng.randf() >= chance:
				continue
			var h := _initial_heights[gx * SIZE + gz]
			if h <= WATER_LEVEL + 1 or h >= 12:
				continue
			if Vector2(gx + 0.5, gz + 0.5).distance_to(center) < PLATEAU_RADIUS + 2.0:
				continue
			var col := Vector2i(gx, gz)
			if _blocked_columns.has(col):
				continue
			_blocked_columns[col] = true
			_grow_tree(gx - HALF, gz - HALF, h)


## Árvores são BLOCOS de verdade (tronco + folhas) — dá pra derrubar minerando.
func _grow_tree(x: int, z: int, ground_h: int) -> void:
	var trunk_height := _rng.randi_range(3, 5)
	for i in trunk_height:
		_blocks[Vector3i(x, ground_h + i, z)] = WOOD
	var top := ground_h + trunk_height
	for lx in range(-1, 2):
		for lz in range(-1, 2):
			for ly in range(-1, 1):
				var cell := Vector3i(x + lx, top + ly, z + lz)
				if absi(lx) + absi(lz) == 2 and ly == 0:
					continue # camada de cima sem cantos
				if not _blocks.has(cell):
					_blocks[cell] = LEAVES
	_blocks[Vector3i(x, top + 1, z)] = LEAVES


## -------------------------------------------------------------------- malha

func _create_chunk_nodes() -> void:
	var chunks_per_axis := SIZE / CHUNK_SIZE
	for cx in chunks_per_axis:
		for cz in chunks_per_axis:
			var mesh_instance := MeshInstance3D.new()
			mesh_instance.material_override = _block_material
			add_child(mesh_instance)
			var body := StaticBody3D.new()
			var shape := CollisionShape3D.new()
			body.add_child(shape)
			add_child(body)
			_chunks[Vector2i(cx, cz)] = {"mesh": mesh_instance, "shape": shape}


func _chunk_key_for(cell: Vector3i) -> Vector2i:
	return Vector2i(
		floori(float(cell.x + HALF) / CHUNK_SIZE),
		floori(float(cell.z + HALF) / CHUNK_SIZE))


## O chunk da célula + vizinhos quando ela está na borda (a face exposta do
## chunk ao lado precisa remalhar também).
func _chunks_touching(cell: Vector3i) -> Array:
	var keys := [_chunk_key_for(cell)]
	for offset in [Vector3i(1, 0, 0), Vector3i(-1, 0, 0), Vector3i(0, 0, 1), Vector3i(0, 0, -1)]:
		var neighbor_key := _chunk_key_for(cell + offset)
		if not keys.has(neighbor_key) and _chunks.has(neighbor_key):
			keys.append(neighbor_key)
	return keys.filter(func(k): return _chunks.has(k))


func _rebuild_chunk(chunk_key: Vector2i) -> void:
	var chunk: Dictionary = _chunks[chunk_key]
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var base_x := chunk_key.x * CHUNK_SIZE - HALF
	var base_z := chunk_key.y * CHUNK_SIZE - HALF
	var has_faces := false

	for lx in CHUNK_SIZE:
		for lz in CHUNK_SIZE:
			for y in MAX_Y:
				var cell := Vector3i(base_x + lx, y, base_z + lz)
				var id: int = _blocks.get(cell, AIR)
				if id == AIR:
					continue
				var jitter := 0.9 + 0.15 * float(posmod(hash(cell), 1000)) / 1000.0
				for face in FACES:
					if _blocks.has(cell + face["n"]):
						continue # face escondida por vizinho sólido
					has_faces = true
					var color := _face_color(cell, id, face["n"])
					_emit_face(st, cell, face, _tint(color, face["s"] * jitter))

	var mesh_instance: MeshInstance3D = chunk["mesh"]
	var shape: CollisionShape3D = chunk["shape"]
	if not has_faces:
		mesh_instance.mesh = null
		shape.shape = null
		return
	var mesh := st.commit()
	mesh_instance.mesh = mesh
	shape.shape = mesh.create_trimesh_shape()


func _face_color(cell: Vector3i, id: int, normal: Vector3i) -> Color:
	if id == GRASS:
		if normal.y > 0:
			return GRASS_COLORS[biome_at(cell.x, cell.z)]
		return BLOCK_COLORS[DIRT] # lateral do bloco de grama é terra
	return BLOCK_COLORS[id]


func _emit_face(st: SurfaceTool, cell: Vector3i, face: Dictionary, color: Color) -> void:
	var origin := Vector3(cell)
	var corners: Array = face["c"]
	st.set_color(color)
	st.set_normal(Vector3(face["n"]))
	st.add_vertex(origin + corners[0])
	st.add_vertex(origin + corners[1])
	st.add_vertex(origin + corners[2])
	st.add_vertex(origin + corners[0])
	st.add_vertex(origin + corners[2])
	st.add_vertex(origin + corners[3])


func _build_water_mesh() -> void:
	if _water_cells.is_empty():
		return
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_color(Color.WHITE)
	st.set_normal(Vector3.UP)
	for cell in _water_cells:
		var x0 := cell.x - 0.5
		var z0 := cell.z - 0.5
		st.add_vertex(Vector3(x0, cell.y, z0))
		st.add_vertex(Vector3(x0 + 1, cell.y, z0))
		st.add_vertex(Vector3(x0 + 1, cell.y, z0 + 1))
		st.add_vertex(Vector3(x0, cell.y, z0))
		st.add_vertex(Vector3(x0 + 1, cell.y, z0 + 1))
		st.add_vertex(Vector3(x0, cell.y, z0 + 1))
	var material := StandardMaterial3D.new()
	material.albedo_color = COLOR_WATER
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.2
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = st.commit()
	mesh_instance.material_override = material
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)


## ---------------------------------------------------------- props e fauna

func _scatter_props() -> void:
	var placed := 0
	var attempts := 0
	while placed < 12 and attempts < 500:
		attempts += 1
		var col := _random_grass_column()
		if col == Vector2i(-1, -1):
			continue
		_blocked_columns[col] = true
		var bush: Node3D = BerryBushScript.new()
		bush.position = _column_top_center(col)
		add_child(bush)
		placed += 1

	placed = 0
	attempts = 0
	while placed < 8 and attempts < 500:
		attempts += 1
		var col := _random_grass_column(Biome.FLORESTA)
		if col == Vector2i(-1, -1):
			continue
		_blocked_columns[col] = true
		var mushroom: Node3D = MushroomScript.new()
		mushroom.position = _column_top_center(col)
		add_child(mushroom)
		placed += 1


func _spawn_animals() -> void:
	for species in ANIMAL_SPECIES:
		var placed := 0
		var attempts := 0
		while placed < int(species["count"]) and attempts < 400:
			attempts += 1
			var gx := _rng.randi_range(2, SIZE - 3)
			var gz := _rng.randi_range(2, SIZE - 3)
			var biome := _biomes[gx * SIZE + gz]
			if not (species["biomes"] as Array).has(biome):
				continue
			var h := _initial_heights[gx * SIZE + gz]
			if h <= WATER_LEVEL:
				continue
			var animal: CharacterBody3D = AnimalScript.new()
			animal.setup(species)
			animal.position = Vector3(gx - HALF + 0.5, h + 0.3, gz - HALF + 0.5)
			add_child(animal)
			placed += 1


func _random_grass_column(required_biome: int = -1) -> Vector2i:
	var gx := _rng.randi_range(2, SIZE - 3)
	var gz := _rng.randi_range(2, SIZE - 3)
	var col := Vector2i(gx, gz)
	if _blocked_columns.has(col):
		return Vector2i(-1, -1)
	var biome := _biomes[gx * SIZE + gz]
	if required_biome >= 0 and biome != required_biome:
		return Vector2i(-1, -1)
	if biome == Biome.DESERTO or biome == Biome.MONTANHA:
		return Vector2i(-1, -1)
	var h := _initial_heights[gx * SIZE + gz]
	if h <= WATER_LEVEL + 1:
		return Vector2i(-1, -1)
	var center := Vector2(SIZE / 2.0, SIZE / 2.0)
	if Vector2(gx + 0.5, gz + 0.5).distance_to(center) < PLATEAU_RADIUS + 2.0:
		return Vector2i(-1, -1)
	return col


func _column_top_center(col: Vector2i) -> Vector3:
	var h := _initial_heights[col.x * SIZE + col.y]
	return Vector3(col.x - HALF + 0.5, h, col.y - HALF + 0.5)


func _tint(color: Color, factor: float) -> Color:
	return Color(color.r * factor, color.g * factor, color.b * factor, 1.0)
