@tool
class_name SoundEffect
extends Resource
## A singular sound effect played using a temporary [AudioStreamPlayer] or [AudioStreamPlayer2D]. [br]
##
## A sound effect gets assigned to 2 groups, one representing all SFX played by 
## the same audio bus, and one for all SFX played at [method play]'s [code]from[/code] node.
## The names of these groups are [code]<bus name>[/code] and
## [code]<node name>/sfx[/code] respectively.

## What the sound effect sounds like.
var stream: AudioStream
## What audio bus the sound effect gets played in.
var audio_bus: StringName = &"Master"
## At what volume the sound effect plays.
## Note that this is an addition to the audio bus' volume and not an overwrite.
var volume: float = 0.0
## At what pitch the sound effect plays.
var pitch: float = 1.0
## Whether or not playing this sound effect should end
## all the other sound effects in the same [member audio_bus].
var overwrite_other_in_bus: bool = false
## Whether or not playing this sound effect should end
## all the other sound effects played at [method play]'s [code]source[/code] node.
var overwrite_other_in_source: bool = false

## Whether or not the sound effect is 2 dimensional.
## (Played at a position in the world.)
var is_2d: bool = true:
	set(val):
		is_2d = val
		notify_property_list_changed()
## Whether or not the position at which the sound effect plays
## is the same as [method play]'s [code]source[/code] node's position.
var inherit_position: bool = true:
	set(val):
		inherit_position = val
		notify_property_list_changed()
## What global position the sound effect plays at
## if [member inherit_position] is [code]false[/code].
var position := Vector2.ZERO
## The volume is attenuated over distance with this as an exponent.
var attenuation: float = 1.0
## Maximum distance from which audio is still hearable.
var max_distance: float = 2000.0

var current_player: Node


## Creates an [AudioStreamPlayer] or [AudioStreamPlayer2D] depending on [member is_2d],
## adds it to [param source], then destroys it when the sound effect finishes.[br]
## Returns an optionally usable reference to the assigned [AudioStreamPlayer] or [AudioStreamPlayer2D].
func play(source: Node) -> Variant:
	if not is_instance_valid(source):
		push_error("Cannot fetch node %s." % source.name)
		return

	if stream == null:
		push_error("SoundEffect has no AudioStream value.")
		return

	if overwrite_other_in_bus:
		source.get_tree().call_group(audio_bus, &"queue_free")
	if overwrite_other_in_source:
		source.get_tree().call_group(source.name + "/sfx", &"queue_free")

	var player = null

	if is_2d:
		if source is not Node2D:
			push_warning(
				"SoundEffect is set to be 2 dimensional, but %s is of type %s.
				The SoundEffect will play at world coordinates (0, 0)." % [
					source.name, source.get_class()
				]
			) 
		player = AudioStreamPlayer2D.new()

		player.attenuation = attenuation
		player.max_distance = max_distance

		if not inherit_position:
			player.position = position
	else:
		player = AudioStreamPlayer.new()

	player.set_stream(stream)
	player.set_bus(audio_bus)
	# For referencing all sfx in the bus.
	player.add_to_group(audio_bus)
	# For referencing all sfx in the parent. (For example, all sfx from a [State].)
	player.add_to_group(source.name + "/sfx")
	player.set_volume_db(volume)
	player.set_pitch_scale(pitch)

	source.add_child(player)

	player.connect(&"finished", player.queue_free)
	player.play()

	current_player = player

	return player


func stop():
	if current_player:
		current_player.queue_free()


func toggle_pause():
	if current_player:
		current_player.set_stream_paused(!current_player.stream_paused)


func pause():
	if current_player:
		current_player.set_stream_paused(true)


func unpause():
	if current_player:
		current_player.set_stream_paused(false)


func _get_property_list() -> Array[Dictionary]:
	var audio_buses: PackedStringArray

	for i in range(AudioServer.bus_count):
		audio_buses.append(AudioServer.get_bus_name(i))

	var properties: Array[Dictionary] = [
		{
			"name": "stream",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			"hint_string": "AudioStream",
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "audio_bus",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(audio_buses),
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "volume",
			"type": TYPE_FLOAT,
			"hint": PROPERTY_HINT_RANGE,
			"hint_string": "0,0,0.005,or_greater,or_less,hide_control,suffix:dB",
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "pitch",
			"type": TYPE_FLOAT,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "overwrite_other_in_bus",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "overwrite_other_in_source",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "2 Dimensional",
			"type": TYPE_NIL,
			"usage": PROPERTY_USAGE_GROUP
		},
		{
			"name": "is_2d",
			"type": TYPE_BOOL,
			"hint": PROPERTY_HINT_GROUP_ENABLE,
			"usage": PROPERTY_USAGE_DEFAULT,
		}
	]

	if is_2d:
		properties.append_array([
			{
				"name": "attenuation",
				"type": TYPE_FLOAT,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			{
				"name": "max_distance",
				"type": TYPE_FLOAT,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			{
				"name": "inherit_position",
				"type": TYPE_BOOL,
				"usage": PROPERTY_USAGE_DEFAULT,
			}
		])

	if is_2d and not inherit_position:
		properties.append(
			{
				"name": "position",
				"type": TYPE_VECTOR2,
				"hint": PROPERTY_HINT_LINK,
				"usage": PROPERTY_USAGE_DEFAULT,
			}
		)

	return properties


func _property_can_revert(_property: StringName) -> bool:
	return true


func _property_get_revert(property: StringName) -> Variant:
	match property:
		&"stream":
			return null
		&"audio_bus":
			return &"Master"
		&"play_at":
			return ""
		&"volume", &"start_delay":
			return 0.0
		&"pitch", &"attenuation":
			return 1.0
		&"max_distance":
			return 2000.0
		&"is_2d", &"inherit_position":
			return true
		&"overwrite_other_in_bus", &"overwrite_other_in_source":
			return false
		&"position":
			return Vector2.ZERO

	return null
