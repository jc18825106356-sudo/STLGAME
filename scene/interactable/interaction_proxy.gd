class_name InteractionProxy extends Interactable

var _owner: Enemy

func _ready() -> void:
	_owner = get_parent() as Enemy
	prompt = _owner.prompt if _owner else ""

func interactor(player: CharacterBody2D) -> void:
	_player = player
	_owner.interactor(player)
