class_name HealthComponent extends Node

signal died()
signal health_changed(current: int, max_hp: int)

@export var max_health: int = 100

var health: int

func _ready() -> void:
	health = max_health

func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	health_changed.emit(health, max_health)
	if health == 0:
		died.emit()

func heal(amount: int) -> void:
	health = min(max_health, health + amount)
	health_changed.emit(health, max_health)

func is_dead() -> bool:
	return health == 0
