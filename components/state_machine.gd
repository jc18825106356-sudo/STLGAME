class_name StateMachine extends Node

signal state_changed(previous: StringName, current: StringName)

@export var initial_state: StringName
@export var debug_mode: bool = false

var _current_state: StringName
var _states: Dictionary = {}
var _entered: bool = false

func _ready() -> void:
	set_process(true)
	_current_state = initial_state

func add_state(state_name: StringName, enter_func: Callable, process_func: Callable, exit_func: Callable = Callable()) -> void:
	_states[state_name] = {
		"enter": enter_func,
		"process": process_func,
		"exit": exit_func,
	}

func transition_to(new_state: StringName) -> void:
	if new_state == _current_state:
		return
	if not _states.has(new_state):
		return
	var previous = _current_state
	if _states.has(_current_state) and _states[_current_state].exit.is_valid():
		_states[_current_state].exit.call()
	_current_state = new_state
	_states[_current_state].enter.call()
	state_changed.emit(previous, _current_state)
	if debug_mode:
		print("状态机: %s -> %s" % [previous, new_state])

func current_state() -> StringName:
	return _current_state

func is_state(state_name: StringName) -> bool:
	return _current_state == state_name

func _process(delta: float) -> void:
	if not _entered and _states.has(_current_state):
		_entered = true
		_states[_current_state].enter.call()
	if _states.has(_current_state) and _states[_current_state].process.is_valid():
		_states[_current_state].process.call(delta)
