@abstract
class_name State
extends Node
## Abstract state class with behavior that affects a target node.

## The current active substate.
var live_substate: State = null

## The target of this state machine's behavior.
var actor: Node = null

## The root of the state machine.
var manager: StateManager = null

## Cache of StateLinks to other states in the machine.
var _link_cache: Dictionary[StringName, StateLink] = {}

## True when on the first cycle of the physics loop.
var _first_cycle: bool = true


func _to_string():
	return str(name)


## Calls the fixed tick functions
func tick_hook() -> void:
	if _first_cycle:
		_first_tick()
		_first_cycle = false
	else:
		_subsequent_ticks()

	_physics_tick()


## Call a callable from a function name and given arguments.
func call_func(function_name: StringName, arguments := []):
	var callable := Callable(self, function_name)

	callable.callv(arguments)


## Call a function on this state and its entire descendant family.
func recurse_descendents(function_name: StringName, arguments := []):
	call_func(function_name, arguments)

	for child in get_children():
		if child is State:
			child.recurse_descendents(function_name, arguments)


## Call a function on this state and all its live descendents.
func recurse_live(function_name: StringName, arguments := [], reverse := false):
	if reverse:
		_call_live(&"recurse_live", [function_name, arguments, true])
		call_func(function_name, arguments)
	else:
		call_func(function_name, arguments)
		_call_live(&"recurse_live", [function_name, arguments, false])


## Trigger entrance events for a new state.
func trigger_enter(handover: Variant):
	_first_cycle = true
	_on_enter(handover)


## Trigger exit events for a new state.
func trigger_exit():
	_first_cycle = true
	_on_exit()


## Ditch this state and all its descendents,
## making this branch of the state tree inactive.
func ditch_state():
	trigger_exit()

	# Ditch live descendents
	if live_substate == null:
		return

	live_substate.ditch_state()
	live_substate = null


## Artificially restart the current state.
func reset_state(handover: Variant = null):
	trigger_exit()
	trigger_enter(handover)


## Artificially set this actor's state through its name as seen in its [StateManager].
func set_to_state(state: StringName, handover: Variant = null):
	call_deferred(&"_switch_leaf", _get_link(state), handover)


## Get the active leaf of the machine.
func get_leaf() -> State:
	if live_substate == null:
		return self
	return live_substate.get_leaf()


## Activate a sibling state.
func switch_substate(new_state: State, handover: Variant = null):
	if new_state == live_substate:
		return
	if new_state == null:
		return

	if live_substate != null:
		live_substate.ditch_state()

	live_substate = new_state
	new_state.trigger_enter(handover)


## Probe the active substate for a state to switch to.
## This is based on its transition rules defined in _trans_rules().
## If a state is found, switch to that state.
func probe_switch(defer: bool = false) -> void:
	if not _is_live():
		return

	var link_name
	var handover = null

	var data = _defer_rules() if defer else _trans_rules()

	if data is Array:
		link_name = data[0]
		handover = data[1]
	else:
		link_name = data

	# Only switch if we need to.
	if not link_name.is_empty():
		var link = _get_link(link_name)

		_switch_leaf(link, handover)


## Get a link to the given state.
func _get_link(key: StringName) -> StateLink:
	if _link_cache.has(key):
		return _link_cache[key]

	return _cache_link(key)


## Cache a link to a state.
func _cache_link(key: StringName) -> StateLink:
	var target = manager.find_child(key)

	# To find where the invalid state is referenced, use the CTRL+SHIFT+F
	# hotkey to search for its name in every script file.
	assert(target != null, "State %s does not exist." % key)

	var link = StateLink.new(self, target)
	_link_cache[key] = link
	return link


## Reroute the active path to select a given state as the active leaf.
func _switch_leaf(link: StateLink, handover = null) -> void:
	var path: Array[State] = link.get_path()
	var states_in_path: int = link.get_length()
	var diversion_idx: int = link.get_peak_index()
	var last_idx: int = states_in_path - 1

	var current_state: State = self

	for i in states_in_path:
		var next_state: State = path[i]

		if i <= diversion_idx:
			ditch_state()
		else:
			current_state.switch_substate(next_state, handover if i == last_idx else null)

		assert(current_state != next_state)
		current_state = next_state

	current_state.probe_switch(true)


## Call a function on the live substate, but only if there is one.
func _call_live(function_name: StringName, arguments := []):
	if live_substate != null:
		live_substate.call_func(function_name, arguments)


## Check if this state is live.
func _is_live() -> bool:
	var parent = get_parent()

	if parent is not State:
		return true
	if parent.live_substate == self:
		return true

	return false


## Called on every cycle of the physics process loop.
func _physics_tick() -> void:
	pass


## Called on the first cycle of the physics process loop.
func _first_tick() -> void:
	pass


## Called on every cycle of the physics process loop minus the first.
func _subsequent_ticks() -> void:
	pass


## Called when the state becomes active.
func _on_enter(_param: Variant) -> void:
	pass


## Called when the state is deactivated.
func _on_exit() -> void:
	pass


## Return the name of a state for the parent to switch to, or `null` for no change.
## This is called by the parent state during probe_switch() at the start of the physics tick.
## This function should be used to define the transition rules for the state.
func _trans_rules() -> Variant:
	return &""


## Return the name of a passthrough state.
## When this state is switched to, immediately switch to that state.
## This means that other states don't have to guess the behavior of this state
## when switching to a child of it.
func _defer_rules() -> Variant:
	return &""
