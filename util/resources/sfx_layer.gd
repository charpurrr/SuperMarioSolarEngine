class_name SFXLayer
extends Resource
## A collection of sound effects for a single action.
## Useful if you want varying sound effects.

## List of possible sound effect(s) this layer can iterate through.
@export var sfx_list: Array[SoundEffect]

## Whether or not a sound effect can play more than once in a row.
@export var force_new: bool = false
## How many seconds should pass before the sound effect(s) can get repeated if loop is enabled.
@export var repeat_delay: float = 0.0

var repeat_timers: Dictionary[SoundEffect, SceneTreeTimer]

var last_pick: SoundEffect
var new_pick: SoundEffect


## Plays a sound effect from the list at a specific node.
func play_sfx_at(node: Node):
	if node == null or sfx_list.is_empty():
		return

	new_pick = sfx_list.pick_random()

	if force_new and sfx_list.size() > 1:
		while new_pick == last_pick:
			new_pick = sfx_list.pick_random()

	for sfx in sfx_list:
		if repeat_timers.get(sfx) == null:
			repeat_timers.set(sfx, node.get_tree().create_timer(0))

		if repeat_timers.get(sfx).time_left <= 0:
			new_pick.play(node)
			last_pick = new_pick

			if repeat_delay != 0:
				repeat_timers.set(sfx, node.get_tree().create_timer(repeat_delay))
