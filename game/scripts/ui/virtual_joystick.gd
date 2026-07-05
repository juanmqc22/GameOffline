extends Control
class_name VirtualJoystick
## Joystick virtual simples (polegar esquerdo). Sem depender de texturas —
## desenha dois círculos via _draw(). Trocar por arte depois é só sobrescrever _draw().

@export var radius: float = 80.0
@export var knob_radius: float = 32.0

var output: Vector2 = Vector2.ZERO # -1..1 em x/y

var _touch_index: int = -1
var _base_position: Vector2 = Vector2.ZERO
var _knob_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	_base_position = size / 2.0
	_knob_position = _base_position


func _draw() -> void:
	draw_circle(_base_position, radius, Color(1, 1, 1, 0.15))
	draw_circle(_knob_position, knob_radius, Color(1, 1, 1, 0.35))


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			_touch_index = event.index
			_base_position = event.position
			_knob_position = event.position
			queue_redraw()
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			_knob_position = _base_position
			output = Vector2.ZERO
			queue_redraw()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		var delta := event.position - _base_position
		var clamped := delta.limit_length(radius)
		_knob_position = _base_position + clamped
		output = clamped / radius
		queue_redraw()
