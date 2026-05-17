class_name HealthBar extends Node2D

@export var bar_width: float = 32.0
@export var bar_height: float = 4.0
@export var y_offset: float = -24.0
@export var bg_color: Color = Color(0.0, 0.0, 0.0, 0.6)
@export var healthy_color: Color = Color(0.0, 0.9, 0.0, 0.9)
@export var low_color: Color = Color(1.0, 0.0, 0.0, 0.9)

var _health_component: HealthComponent
var _ratio: float = 1.0

func _ready() -> void:
	_health_component = get_parent().get_node_or_null("HealthComponent") as HealthComponent
	if _health_component:
		_health_component.health_changed.connect(_on_health_changed)
		_update_ratio(_health_component.health, _health_component.max_health)

func _on_health_changed(current: int, max_hp: int) -> void:
	_update_ratio(current, max_hp)

func _update_ratio(current: int, max_hp: int) -> void:
	_ratio = float(current) / max_hp
	queue_redraw()

func _process(_delta: float) -> void:
	if _health_component and _health_component.is_dead():
		visible = false

func _draw() -> void:
	var bg := Rect2(Vector2.ZERO, Vector2(bar_width, bar_height))
	var fg := Rect2(Vector2.ZERO, Vector2(bar_width * _ratio, bar_height))
	var fg_color := low_color if _ratio < 0.3 else healthy_color.lerp(low_color, 1.0 - _ratio)
	draw_set_transform(Vector2(-bar_width / 2.0, y_offset))
	draw_rect(bg, bg_color)
	draw_rect(fg, fg_color)
	draw_rect(bg, Color.BLACK, false, 1.0)
