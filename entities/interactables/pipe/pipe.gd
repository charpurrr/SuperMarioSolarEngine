@tool
class_name WarpPipe
extends Node2D
## Pipe that can be entered to send the player to a new location.


## Whether the [WarpPipe] has an end exit or not.
@export var end_exit := false:
	set(value):
		end_exit = value
		_build_pipe()

## Maps a direction to the next possible directions from it.
const available_direction_map: Dictionary = {
	"Left": ["Up", "Down"],
	"Right": ["Up", "Down"],
	"Up": ["Left", "Right"],
	"Down": ["Left", "Right"]
}
## Maps a direction to its next clockwise-ordered direction.
## Up --> Left --> Down --> Right --> Up
const clockwise_direction: Dictionary = {
	"Up": "Left",
	"Left": "Down",
	"Down": "Right",
	"Right": "Up"
}
## Maps a direction to its opposite.
const opposite_direction: Dictionary = {
	"Up": "Down",
	"Left": "Right",
	"Down": "Up",
	"Right": "Left"
}
## Returns the amount of clockwise steps needed to go from
## [param start] to [param end].
func get_direction_steps_with_end(start: String, end: String) -> int:
	var cur_step = start
	var steps: int = 0
	while cur_step != end:
		cur_step = clockwise_direction[cur_step]
		steps += 1
	return steps
## Returns the reached clockwise direction starting from
## [param start] with a given amount of [param steps].
func get_direction_end_with_steps(start: String, steps: int) -> String:
	var cur_step = start
	for i in range(steps):
		cur_step = clockwise_direction[cur_step]
	return cur_step

var old_segment_length: int = 0
var new_segment_length: int = 0
## The different pieces making up the pipe.
@export var segments: Array[PipeSegment]:
	set(value):
		old_segment_length = len(segments)
		new_segment_length = len(value)

		if new_segment_length == 0 or old_segment_length == 0:
			var first_segment := PipeSegment.new()
			first_segment.available_directions = ["Left", "Down", "Up", "Right"]
			first_segment.direction = "Down"
			first_segment.is_connector = false

			if not first_segment.connected_updates:
				first_segment.updated.connect(_build_pipe)
				first_segment.updated_direction.connect(_notify_segment_direction_changed.bind(0))
				first_segment.connected_updates = true

			new_segment_length = 1
			segments = [first_segment]
			_build_pipe()
			return

		for i in range(new_segment_length):
			if not value[i]:
				value[i] = PipeSegment.new()
			if i > 0:
				var dir = value[i-1].direction
				value[i].available_directions = available_direction_map[dir]
			value[i].is_connector = i != 0
			value[i].idx = i
			if not value[i].connected_updates:
				value[i].updated.connect(_build_pipe)
				value[i].updated_direction.connect(_notify_segment_direction_changed.bind(i))
				value[i].connected_updates = true

		segments = value
		_build_pipe()


var segment_inst: Array = []
var build_lock: bool = false

@export_group("Debugging")
## Enables debug markers on pipe pieces to associate them with
## the corresponding [PipeSegment].
@export var debug := false:
	set(value):
		debug = value
		_build_pipe()
## Clears out all instances of pipe pieces in case of
## a pipe build malfunction.
@export_tool_button("Reset segment insts") var a: Callable = func():
	segment_inst.clear()
	for x in get_children(): x.queue_free()
	build_lock = false
	direction_changed_lock = false


@export_group("Node References")
@export var pipe_entrance: PackedScene
@export var pipe_extension: PackedScene
@export var pipe_connector: PackedScene
@export var pipe_debug: PackedScene


## Returns the end point of the [WarpPipe].
func get_end_point() -> Vector2:
	if len(segment_inst) > 0:
		return position + segment_inst[-1][1].get_end_point()
	return position


## Main building function for the pipe.
func _build_pipe():
	if build_lock: return
	build_lock = true

	if segments.is_empty():
		build_lock = false
		return

	var _old := old_segment_length
	var _new := new_segment_length

	if len(segment_inst) == 0:
		var entrance: PipeEntrance = pipe_entrance.instantiate()
		entrance.direction = segments[0].direction

		var entrance_ext: PipeExtension = pipe_extension.instantiate()
		entrance_ext.direction = segments[0].direction
		entrance_ext.scale.y = segments[0].length / 32.0

		segment_inst = [[entrance, entrance_ext, null], null]
		_old = 1
		_new = 1

	var freed_nodes = []

	if end_exit and not segment_inst[-1]:
		var exit: PipeEntrance = pipe_entrance.instantiate()
		segment_inst[-1] = exit
	if not end_exit and segment_inst[-1]:
		freed_nodes.append(segment_inst[-1])
		segment_inst[-1] = null

	var diff := _new - _old
	if diff < 0:
		for i in -diff:
			var deleted = segment_inst.pop_at(-2)
			freed_nodes.append_array(deleted)
	elif diff > 0:
		for i in diff:
			var connector: PipeConnector = pipe_connector.instantiate()
			var connector_ext: PipeExtension = pipe_extension.instantiate()
			segment_inst.insert(-1, [connector, connector_ext, null])

	old_segment_length = _new
	new_segment_length = _new

	for i in len(segments):
		var slot = segment_inst[i]
		if not slot is Array: continue
		if debug and not slot[2]:
			var dbg = pipe_debug.instantiate()
			slot[2] = dbg
		elif not debug and slot[2]:
			freed_nodes.append(slot[2])
			slot[2] = null

	for x in freed_nodes:
		if x: x.queue_free()

	for x in segment_inst:
		if x is Array:
			for y in x:
				if y and not y.is_inside_tree():
					add_child(y)
		elif x and not x.is_inside_tree():
			add_child(x)

	var last_piece = null
	for i in len(segments):
		var cur_segment = segment_inst[i]
		if not cur_segment or cur_segment is PipeEntrance:
			break

		var segment_start = cur_segment[0]
		if segment_start is PipeConnector:
			segment_start.exit_dir = segments[i].direction
			segment_start.entry_dir = segments[i-1].direction
			segment_start.type = "Block" if segments[i].is_block else "Corner"
			segment_start.position = last_piece.get_end_point() if last_piece else Vector2.ZERO
		else:
			segment_start.direction = opposite_direction[segments[i].direction]

		last_piece = segment_start

		var dbg = cur_segment[2]
		if dbg:
			dbg.position = segment_start.position
			if segment_start is PipeConnector:
				dbg.position += segment_start.offset
			else:
				dbg.position += segment_start.get_node("PlayerDetector").position
			dbg.get_node("Index").text = str(i)

		var segment_ext = cur_segment[1]
		segment_ext.direction = segments[i].direction
		segment_ext.scale.y = segments[i].length / 32.0
		segment_ext.position = last_piece.get_end_point() - Vector2(16, 0)
		last_piece = segment_ext

	var pipe_exit = segment_inst[-1]
	if pipe_exit and last_piece:
		pipe_exit.direction = segments[-1].direction
		pipe_exit.position = last_piece.get_end_point()

	build_lock = false


var direction_changed_lock = false
## Applies smart pipe rotation when changing the orientation of one of the segments.
func _notify_segment_direction_changed(idx: int):
	if direction_changed_lock: return
	direction_changed_lock = true

	if idx + 1 < len(segments):
		var main_segment := segments[idx]
		var steps := get_direction_steps_with_end(main_segment.old_direction, main_segment.direction)
		for i in range(idx + 1, len(segments)):
			segments[i].direction = get_direction_end_with_steps(segments[i].direction, steps)
			for available_directions in [["Left", "Right"], ["Up", "Down"]]:
				if segments[i].direction in available_directions:
					segments[i].available_directions = available_directions

	direction_changed_lock = false
	for i in 2:
		call_deferred("_build_pipe")
