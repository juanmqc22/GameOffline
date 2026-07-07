extends DirectionalLight3D
## Sol + céu dirigidos pelo TimeManager: energia e cor da luz, cores do céu
## procedural. Anexado ao DirectionalLight3D da cena principal; cria o
## WorldEnvironment em código (mesma filosofia da UI procedural).

const DAY_SKY_TOP := Color(0.3, 0.55, 0.85)
const DAY_SKY_HORIZON := Color(0.75, 0.85, 0.9)
const NIGHT_SKY_TOP := Color(0.02, 0.03, 0.08)
const NIGHT_SKY_HORIZON := Color(0.05, 0.08, 0.14)
const DAY_LIGHT_COLOR := Color(1.0, 0.97, 0.88)
const NIGHT_LIGHT_COLOR := Color(0.55, 0.62, 0.9)

var _sky_material := ProceduralSkyMaterial.new()


func _ready() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	sky.sky_material = _sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_sky_contribution = 1.0
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)


func _process(_delta: float) -> void:
	var hour: float = TimeManager.game_hour
	# 0 durante a noite, 1 ao meio-dia, transição suave no amanhecer/anoitecer
	var daylight := clampf(sin((hour - 6.0) / 12.0 * PI), 0.0, 1.0)

	rotation_degrees = Vector3(-(10.0 + daylight * 55.0), -30.0, 0.0)
	light_energy = lerpf(0.07, 1.25, daylight) # 0.07 = "luar" pra noite não ser breu
	light_color = NIGHT_LIGHT_COLOR.lerp(DAY_LIGHT_COLOR, daylight)

	_sky_material.sky_top_color = NIGHT_SKY_TOP.lerp(DAY_SKY_TOP, daylight)
	_sky_material.sky_horizon_color = NIGHT_SKY_HORIZON.lerp(DAY_SKY_HORIZON, daylight)
	_sky_material.ground_horizon_color = NIGHT_SKY_HORIZON.lerp(DAY_SKY_HORIZON, daylight)
	_sky_material.ground_bottom_color = NIGHT_SKY_TOP.lerp(Color(0.2, 0.25, 0.2), daylight)
