extends Node3D
class_name BlockWorld
## Mundo em blocos estilo Minecraft (decisão de arte — ver docs/GDD.md seção 16).
## Gera uma ilha de SIZE×SIZE colunas de cubos de 1 m a partir de ruído com seed
## fixa: o mundo é idêntico em toda sessão, então nada dele precisa ir pro save.
## A malha é única (SurfaceTool, só faces visíveis) com cor por vértice — sem
## texturas externas — e a colisão é um trimesh gerado da própria malha.

const SIZE := 48
const HALF := SIZE / 2
const WATER_LEVEL := 3
const PLATEAU_RADIUS := 6.0
const PLATEAU_HEIGHT := 4
const WORLD_SEED := 20260707

const TREE_COUNT := 14
const BUSH_COUNT := 10
const MUSHROOM_COUNT := 8

const COLOR_GRASS := Color(0.38, 0.62, 0.26)
const COLOR_DIRT := Color(0.48, 0.34, 0.22)
const COLOR_STONE := Color(0.5, 0.5, 0.52)
const COLOR_SAND := Color(0.83, 0.77, 0.55)
const COLOR_TRUNK := Color(0.42, 0.29, 0.16)
const COLOR_LEAVES := Color(0.24, 0.5, 0.2)
const COLOR_WATER := Color(0.2, 0.42, 0.75, 0.6)

## Sombreamento por face (o "cheiro" de Minecraft vem daqui: topo claro,
## laterais progressivamente mais escuras, sem depender de luz complexa).
const SHADE_TOP := 1.0
const SHADE_X := 0.8
const SHADE_Z := 0.7
const SHADE_BOTTOM := 0.5

const BerryBushScript := preload("res://scripts/world/berry_bush.gd")
const MushroomScript := preload("res://scripts/world/mushroom.gd")

var _heights := PackedInt32Array()
var _water_cells: Array[Vector3] = []
var _blocked_columns := {} # Vector2i -> true (árvores/arbustos já ocupam a coluna)
var _tree_columns: Array[Vector2i] = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("block_world")
	_rng.seed = WORLD_SEED
	_generate_heights()
	_pick_tree_spots()
	_build_solid_mesh()
	_build_water_mesh()
	_scatter_props()


## Altura (em blocos) do topo do terreno na coluna sob a posição dada.
func height_at(world_pos: Vector3) -> float:
	var gx := int(floorf(world_pos.x)) + HALF
	var gz := int(floorf(world_pos.z)) + HALF
	return float(_column_height(gx, gz))


func nearest_water_distance(world_pos: Vector3) -> float:
	var best := INF
	for cell in _water_cells:
		best = minf(best, cell.distance_to(world_pos))
	return best


func _column_height(gx: int, gz: int) -> int:
	if gx < 0 or gz < 0 or gx >= SIZE or gz >= SIZE:
		return 0
	return _heights[gx * SIZE + gz]


func _generate_heights() -> void:
	var noise := FastNoiseLite.new()
	noise.seed = WORLD_SEED
	noise.frequency = 0.07
	_heights.resize(SIZE * SIZE)
	var center := Vector2(SIZE / 2.0, SIZE / 2.0)
	for gx in SIZE:
		for gz in SIZE:
			var v := noise.get_noise_2d(float(gx), float(gz)) * 0.5 + 0.5
			var h := 2 + int(roundf(v * 5.0)) # 2..7; abaixo de WATER_LEVEL vira lago raso
			var dist := Vector2(gx + 0.5, gz + 0.5).distance_to(center)
			if dist <= PLATEAU_RADIUS:
				h = PLATEAU_HEIGHT # platô plano de spawn no centro da ilha
			elif dist <= PLATEAU_RADIUS + 3.0:
				h = clampi(h, PLATEAU_HEIGHT - 1, PLATEAU_HEIGHT + 1)
			_heights[gx * SIZE + gz] = h


func _pick_tree_spots() -> void:
	var center := Vector2(SIZE / 2.0, SIZE / 2.0)
	var attempts := 0
	while _tree_columns.size() < TREE_COUNT and attempts < 400:
		attempts += 1
		var gx := _rng.randi_range(2, SIZE - 3)
		var gz := _rng.randi_range(2, SIZE - 3)
		var col := Vector2i(gx, gz)
		if _blocked_columns.has(col):
			continue
		if _column_height(gx, gz) <= WATER_LEVEL:
			continue
		if Vector2(gx + 0.5, gz + 0.5).distance_to(center) < PLATEAU_RADIUS + 4.0:
			continue
		var too_close := false
		for other in _tree_columns:
			if Vector2(other - col).length() < 4.0:
				too_close = true
				break
		if too_close:
			continue
		_tree_columns.append(col)
		_blocked_columns[col] = true


func _build_solid_mesh() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for gx in SIZE:
		for gz in SIZE:
			var h := _column_height(gx, gz)
			var wx := float(gx - HALF)
			var wz := float(gz - HALF)
			var jitter := _column_jitter(gx, gz)
			var top_base := COLOR_SAND if h <= WATER_LEVEL else COLOR_GRASS
			_add_quad(st,
				Vector3(wx, h, wz), Vector3(wx + 1, h, wz),
				Vector3(wx + 1, h, wz + 1), Vector3(wx, h, wz + 1),
				Vector3.UP, _tint(top_base, SHADE_TOP * jitter))
			_add_column_sides(st, gx, gz, h, jitter)

	for col in _tree_columns:
		_add_tree(st, col)

	var mesh := st.commit()
	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 1.0
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	add_child(mesh_instance)

	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = mesh.create_trimesh_shape()
	body.add_child(shape)
	add_child(body)


## Só desenha as faces laterais expostas (vizinho mais baixo) — meshing clássico
## de voxel. Terra nas duas camadas de cima, pedra abaixo.
func _add_column_sides(st: SurfaceTool, gx: int, gz: int, h: int, jitter: float) -> void:
	var wx := float(gx - HALF)
	var wz := float(gz - HALF)
	for dir in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var neighbor_h := _column_height(gx + dir.x, gz + dir.y)
		var shade := SHADE_X if dir.y == 0 else SHADE_Z
		for y in range(neighbor_h, h):
			var base := COLOR_DIRT if y >= h - 2 else COLOR_STONE
			_add_side_face(st, wx, wz, y, dir, _tint(base, shade * jitter))


func _add_side_face(st: SurfaceTool, wx: float, wz: float, y: int, dir: Vector2i, color: Color) -> void:
	var x0 := wx
	var x1 := wx + 1.0
	var z0 := wz
	var z1 := wz + 1.0
	var y0 := float(y)
	var y1 := float(y + 1)
	if dir == Vector2i(1, 0): # leste (+X)
		_add_quad(st, Vector3(x1, y0, z0), Vector3(x1, y0, z1), Vector3(x1, y1, z1), Vector3(x1, y1, z0), Vector3.RIGHT, color)
	elif dir == Vector2i(-1, 0): # oeste (−X)
		_add_quad(st, Vector3(x0, y0, z1), Vector3(x0, y0, z0), Vector3(x0, y1, z0), Vector3(x0, y1, z1), Vector3.LEFT, color)
	elif dir == Vector2i(0, 1): # sul (+Z)
		_add_quad(st, Vector3(x1, y0, z1), Vector3(x0, y0, z1), Vector3(x0, y1, z1), Vector3(x1, y1, z1), Vector3.BACK, color)
	else: # norte (−Z)
		_add_quad(st, Vector3(x0, y0, z0), Vector3(x1, y0, z0), Vector3(x1, y1, z0), Vector3(x0, y1, z0), Vector3.FORWARD, color)


func _add_tree(st: SurfaceTool, col: Vector2i) -> void:
	var h := _column_height(col.x, col.y)
	var wx := col.x - HALF
	var wz := col.y - HALF
	var trunk_height := _rng.randi_range(3, 4)
	for i in trunk_height:
		_add_cube(st, Vector3i(wx, h + i, wz), COLOR_TRUNK)
	var top := h + trunk_height
	for lx in range(-1, 2):
		for lz in range(-1, 2):
			var leaf := _tint(COLOR_LEAVES, 0.85 + _rng.randf() * 0.3)
			if not (lx == 0 and lz == 0): # centro da camada de baixo é o tronco
				_add_cube(st, Vector3i(wx + lx, top - 1, wz + lz), leaf)
			if absi(lx) + absi(lz) < 2: # camada de cima sem os cantos
				_add_cube(st, Vector3i(wx + lx, top, wz + lz), leaf)
	_add_cube(st, Vector3i(wx, top + 1, wz), _tint(COLOR_LEAVES, 1.05))


func _add_cube(st: SurfaceTool, cell: Vector3i, color: Color) -> void:
	var x0 := float(cell.x)
	var x1 := x0 + 1.0
	var y0 := float(cell.y)
	var y1 := y0 + 1.0
	var z0 := float(cell.z)
	var z1 := z0 + 1.0
	_add_quad(st, Vector3(x0, y1, z0), Vector3(x1, y1, z0), Vector3(x1, y1, z1), Vector3(x0, y1, z1), Vector3.UP, _tint(color, SHADE_TOP))
	_add_quad(st, Vector3(x0, y0, z1), Vector3(x1, y0, z1), Vector3(x1, y0, z0), Vector3(x0, y0, z0), Vector3.DOWN, _tint(color, SHADE_BOTTOM))
	_add_quad(st, Vector3(x1, y0, z0), Vector3(x1, y0, z1), Vector3(x1, y1, z1), Vector3(x1, y1, z0), Vector3.RIGHT, _tint(color, SHADE_X))
	_add_quad(st, Vector3(x0, y0, z1), Vector3(x0, y0, z0), Vector3(x0, y1, z0), Vector3(x0, y1, z1), Vector3.LEFT, _tint(color, SHADE_X))
	_add_quad(st, Vector3(x1, y0, z1), Vector3(x0, y0, z1), Vector3(x0, y1, z1), Vector3(x1, y1, z1), Vector3.BACK, _tint(color, SHADE_Z))
	_add_quad(st, Vector3(x0, y0, z0), Vector3(x1, y0, z0), Vector3(x1, y1, z0), Vector3(x0, y1, z0), Vector3.FORWARD, _tint(color, SHADE_Z))


## Godot usa winding horário para faces frontais — a ordem dos vértices aqui
## foi conferida contra isso (cross(v1-v0, v2-v0) == -normal).
func _add_quad(st: SurfaceTool, v0: Vector3, v1: Vector3, v2: Vector3, v3: Vector3, normal: Vector3, color: Color) -> void:
	st.set_color(color)
	st.set_normal(normal)
	st.add_vertex(v0)
	st.add_vertex(v1)
	st.add_vertex(v2)
	st.add_vertex(v0)
	st.add_vertex(v2)
	st.add_vertex(v3)


func _build_water_mesh() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var has_water := false
	var y := WATER_LEVEL - 0.15
	for gx in SIZE:
		for gz in SIZE:
			if _column_height(gx, gz) >= WATER_LEVEL:
				continue
			has_water = true
			var wx := float(gx - HALF)
			var wz := float(gz - HALF)
			_add_quad(st,
				Vector3(wx, y, wz), Vector3(wx + 1, y, wz),
				Vector3(wx + 1, y, wz + 1), Vector3(wx, y, wz + 1),
				Vector3.UP, Color.WHITE)
			_water_cells.append(Vector3(wx + 0.5, y, wz + 0.5))
	if not has_water:
		return
	var material := StandardMaterial3D.new()
	material.albedo_color = COLOR_WATER
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.2
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = st.commit()
	mesh_instance.material_override = material
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)


func _scatter_props() -> void:
	var center := Vector2(SIZE / 2.0, SIZE / 2.0)

	var placed := 0
	var attempts := 0
	while placed < BUSH_COUNT and attempts < 400:
		attempts += 1
		var gx := _rng.randi_range(2, SIZE - 3)
		var gz := _rng.randi_range(2, SIZE - 3)
		var col := Vector2i(gx, gz)
		var h := _column_height(gx, gz)
		if _blocked_columns.has(col) or h <= WATER_LEVEL:
			continue
		if Vector2(gx + 0.5, gz + 0.5).distance_to(center) < PLATEAU_RADIUS + 2.0:
			continue
		_blocked_columns[col] = true
		var bush: Node3D = BerryBushScript.new()
		bush.position = Vector3(gx - HALF + 0.5, h, gz - HALF + 0.5)
		add_child(bush)
		placed += 1

	placed = 0
	attempts = 0
	while placed < MUSHROOM_COUNT and attempts < 400 and not _tree_columns.is_empty():
		attempts += 1
		var tree := _tree_columns[_rng.randi_range(0, _tree_columns.size() - 1)]
		var col := tree + Vector2i(_rng.randi_range(-2, 2), _rng.randi_range(-2, 2))
		if col == tree or _blocked_columns.has(col):
			continue
		if col.x < 1 or col.y < 1 or col.x >= SIZE - 1 or col.y >= SIZE - 1:
			continue
		var h := _column_height(col.x, col.y)
		if h <= WATER_LEVEL:
			continue
		_blocked_columns[col] = true
		var mushroom: Node3D = MushroomScript.new()
		mushroom.position = Vector3(col.x - HALF + 0.5, h, col.y - HALF + 0.5)
		add_child(mushroom)
		placed += 1


## Variação sutil de tom por coluna (o mesmo "ruído de grama" do Minecraft),
## determinística pra não mudar entre sessões.
func _column_jitter(gx: int, gz: int) -> float:
	return 0.9 + 0.15 * float(posmod(hash(Vector2i(gx, gz)), 1000)) / 1000.0


func _tint(color: Color, factor: float) -> Color:
	return Color(color.r * factor, color.g * factor, color.b * factor, 1.0)
