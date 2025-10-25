class_name SFX
extends RefCounted
## Utility class for creating and destroying a singular sound effect
## using a temporary [AudioStreamPlayer]. [br]
##
## A sound effect gets assigned to 2 groups, one representing all SFX played by 
## the same audio bus, and one for all SFX played by the caller node.
## The names of these groups are [code]<bus name>[/code] and
## [code]<node name>/sfx[/code] respectively.


## Creates an [AudioStreamPlayer], assigns the corresponding data,
## adds it to [param node], then destroys it when finished.[br]
## Returns an optionally usable reference to the assigned [AudioStreamPlayer].
static func play_sfx(
		stream: AudioStream,
		bus: StringName,
		node: Node,
		volume: float = 0.0,
		pitch: float = 1.0,
	) -> AudioStreamPlayer:
	if not node.is_inside_tree() or stream == null:
		return

	# If no bus is specified, simply play to the Master bus.
	if bus.is_empty():
		bus = &"Master"

	var player := AudioStreamPlayer.new()

	player.set_stream(stream)
	player.set_bus(bus)
	# For referencing all sfx in the bus.
	player.add_to_group(bus)
	# For referencing all sfx in the caller. (For example, all sfx from a [State].)
	player.add_to_group(node.name + "/sfx")
	player.set_volume_db(volume)
	player.set_pitch_scale(pitch)

	node.add_child(player)

	player.connect(&"finished", player.queue_free)
	player.play()

	return player
