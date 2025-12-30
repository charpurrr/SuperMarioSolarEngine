class_name SFXLayer
extends Resource
## A collection of sound effects for a single action.
## Useful if you want varying sound effects.

## List of possible sound effect(s) this layer can iterate through.
@export var sfx_list: Array
## What audio bus this layer should play its sound effect(s) to.
@export var bus: StringName

## How many seconds pass before the sound effect(s) play.
@export var start_delay: float = 0.0
## How many seconds should pass before the sound effect(s) can get repeated.
@export var repeat_delay: float = 0.0
## Whether or not a sound effect can play more than once in a row.
@export var force_new: bool = false
## Whether or not playing these sound effect(s) should end
## all the other sound effects in the same AudioBus.
@export var overwrite_other: bool = true
## State machine only:[br]
## Whether or not changing the state should end the sound effect(s) early.
@export var cutoff_sfx: bool = true

var last_pick: AudioStream
var new_pick: AudioStream
var repeat_timer: SceneTreeTimer


## Plays a sound effect from the list at a specific node.
func play_sfx_at(node: Node):
	var start_timer: SceneTreeTimer = node.get_tree().create_timer(start_delay)

	if start_delay != 0:
		await start_timer.timeout

	if node == null:
		return

	new_pick = sfx_list.pick_random()

	if force_new and sfx_list.size() > 1:
		while new_pick == last_pick:
			new_pick = sfx_list.pick_random()

	if overwrite_other:
		node.get_tree().call_group(bus, &"queue_free")

	if !repeat_timer:
		repeat_timer = node.get_tree().create_timer(0)

	if repeat_timer.time_left <= 0:
		SFX.play_sfx(new_pick, bus, node)
		last_pick = new_pick
		
		if repeat_delay:
			repeat_timer = node.get_tree().create_timer(repeat_delay)
