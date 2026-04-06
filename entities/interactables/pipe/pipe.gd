@tool
class_name WarpPipe
extends Node2D
## Pipe that can optionally be entered to send the player to a new location.
##
## Composed of one or more [PipeSegment]s which define the pipe's shape and layout.
## The pipe is rebuilt automatically whenever segments or properties change.

## Maps a direction to the two perpendicular directions available for the next segment.
const available_direction_map: Dictionary = {
	"Left": ["Up", "Down"],
	"Right": ["Up", "Down"],
	"Up": ["Left", "Right"],
	"Down": ["Left", "Right"]
}

## Maps a direction to its next clockwise-ordered direction.
## Up -> Right -> Down -> Left -> Up
const clockwise_direction: Dictionary = {
	"Up": "Right",
	"Right": "Down",
	"Down": "Left",
	"Left": "Up"
}

## Maps a direction to its opposite.
const opposite_direction: Dictionary = {
	"Up": "Down",
	"Left": "Right",
	"Down": "Up",
	"Right": "Left"
}

## Whether the pipe has a capped exit at its ending.
## If false, the pipe is open-ended.
@export var end_exit := false:
	set(val):
		end_exit = val
		if is_node_ready():
			_build_pipe()

## The segments that define the pipe's shape.
## Adding or removing segments updates the pipe layout automatically.[br][br]
## [b]Note:[/b] The first segment is always the entrance and cannot be a connector.
@export var segments: Array[PipeSegment]:
	set(val):
		var old := segments.size()
		var new := val.size()

		if new == 0 or old == 0:
			var first_segment := PipeSegment.new()
			first_segment.available_directions = ["Left", "Down", "Up", "Right"]
			first_segment.direction = "Down"
			first_segment.is_connector = false

			if not first_segment.updated.is_connected(_build_pipe):
				first_segment.updated.connect(_build_pipe)
			if not first_segment.direction_updated.is_connected(_segment_direction_changed):
				first_segment.direction_updated.connect(_segment_direction_changed.bind(0))

			segments = [first_segment]

			if is_node_ready():
				_build_pipe()
			return

		for i: int in new:
			if not val[i]:
				val[i] = PipeSegment.new()

			if i > 0:
				var dir: String = val[i - 1].direction
				val[i].available_directions = available_direction_map[dir]

			val[i].is_connector = i != 0
			val[i].idx = i

			if not val[i].updated.is_connected(_build_pipe):
				val[i].updated.connect(_build_pipe)
			if not val[i].direction_updated.is_connected(_segment_direction_changed):
				val[i].direction_updated.connect(_segment_direction_changed.bind(i))

		segments = val

		if is_node_ready():
			_build_pipe()

## If true, renders debug markers on each segment showing its index and entry point.
@export var debug := false:
	set(val):
		debug = val
		if is_node_ready():
			_build_pipe()

@export_category("References")
## The scene for pipe entrances. Used for the first segment and optionally the exit.
@export var pipe_entrance: PackedScene
## The scene for pipe extensions, which are scaled to match each segment's length.
@export var pipe_extension: PackedScene
## The scene for pipe connectors between segments. Can render as a corner or a block.
@export var pipe_connector: PackedScene
## The scene for debug markers, shown per-segment when [member debug] is enabled.
@export var pipe_debug: PackedScene

## Flat array mirroring [member segments], holding the instantiated scene nodes for each slot.
## Each entry is either an [Array] of 
## [code][connector_or_entrance, extension, debug_marker][/code],
## or a [PipeEntrance] node for the end exit (the last element).
var segment_inst: Array = []


func _ready() -> void:
	_build_pipe()


## Returns the amount of clockwise steps needed to go from
## [param start] to [param end].
func get_direction_steps_with_end(start: String, end: String) -> int:
	var cur_step := start
	var steps := 0

	while cur_step != end:
		cur_step = clockwise_direction[cur_step]
		steps += 1

	return steps


## Returns the reached clockwise direction starting from
## [param start] with a given amount of [param steps].
func get_direction_end_with_steps(start: String, steps: int) -> String:
	var cur_step := start

	for i: int in steps:
		cur_step = clockwise_direction[cur_step]

	return cur_step


## Returns the world-space end point of the pipe (the tip of the last segment).
func get_end_point() -> Vector2:
	if segment_inst.size() > 0:
		return position + segment_inst[-1][1].get_end_point()

	return position


## Rebuilds the pipe's scene nodes to match the current [member segments] data.
## Diffs [member old_segment_length] against [member new_segment_length] to add or
## remove connector slots, then repositions and reconfigures all nodes in order.
func _build_pipe() -> void:
	if segments.is_empty():
		return
	
	# Bootstrap segment_inst if this is the first build.
	if segment_inst.is_empty():
		segment_inst = [[pipe_entrance.instantiate(), pipe_extension.instantiate(), null], null]
	
	var freed_nodes: Array = []
	
	# Add or remove the end exit node based on the end_exit flag.
	if end_exit and not segment_inst[-1]:
		var exit: PipeEntrance = pipe_entrance.instantiate()
		segment_inst[-1] = exit
	
	if not end_exit and segment_inst[-1]:
		freed_nodes.append(segment_inst[-1])
		segment_inst[-1] = null
	
	# Diff segment count and insert/remove connector slots accordingly.
	var diff: int = segments.size() - (segment_inst.size() - 1)
	
	if diff < 0:
		for i: int in -diff:
			var deleted: Array = segment_inst.pop_at(-2)
			freed_nodes.append_array(deleted)
	elif diff > 0:
		for i: int in diff:
			var connector: PipeConnector = pipe_connector.instantiate()
			var connector_ext: PipeExtension = pipe_extension.instantiate()
			segment_inst.insert(-1, [connector, connector_ext, null])
	
	# Add or remove debug marker nodes based on the debug flag.
	# Done before add_child pass so new debug nodes are parented in the same pass.
	for i: int in segments.size():
		var slot: Variant = segment_inst[i]
		
		if not slot is Array:
			continue
		
		if debug and not slot[2]:
			var dbg: Node = pipe_debug.instantiate()
			slot[2] = dbg
		elif not debug and slot[2]:
			freed_nodes.append(slot[2])
			slot[2] = null
	
	for x: Variant in freed_nodes:
		if x:
			x.queue_free()
	
	# Ensure all live nodes are in the scene tree.
	for x: Variant in segment_inst:
		if x is Array:
			for y: Variant in x:
				if y and not y.is_inside_tree():
					add_child(y)
		elif x and not x.is_inside_tree():
			add_child(x)
	
	# Update and seed the entrance before processing connectors.
	var entrance: PipeEntrance = segment_inst[0][0]
	entrance.direction = opposite_direction[segments[0].direction]
	
	var entrance_ext: PipeExtension = segment_inst[0][1]
	entrance_ext.direction = segments[0].direction
	entrance_ext.size.y = segments[0].length
	
	var entrance_dbg: Node = segment_inst[0][2]
	
	if entrance_dbg:
		entrance_dbg.get_node("Index").text = "0"
		entrance_dbg.get_node("ConnectorEndPoint").position = entrance.get_end_point() - 2 * Vector2.ONE
		entrance_dbg.get_node("ExtensionEndPoint").position = entrance_ext.get_end_point() - Vector2.ONE
	
	var last_piece: Variant = entrance_ext
	
	for i: int in range(1, segments.size()):
		var segment: Variant = segment_inst[i]
		
		# Stop if we've reached the trailing exit slot (a PipeEntrance, not an Array).
		if not segment is Array:
			break
		
		var segment_start: PipeConnector = segment[0]
		
		segment_start.exit_dir = segments[i].direction
		segment_start.entry_dir = segments[i - 1].direction
		segment_start.type = "Block" if segments[i].is_block else "Corner"
		segment_start.position = last_piece.get_end_point()
		
		last_piece = segment_start
		
		var segment_ext: PipeExtension = segment[1]
		
		segment_ext.direction = segments[i].direction
		segment_ext.size.y = segments[i].length
		segment_ext.position = last_piece.get_end_point() - segment_ext.get_combined_pivot_offset()
		
		last_piece = segment_ext
		
		var dbg: Node = segment[2]
		
		if dbg:
			dbg.position = segment_start.position + segment_start.offset
			dbg.get_node("Index").text = str(i)
			dbg.get_node("ConnectorEndPoint").position = \
				segment_start.get_end_point() - 2 * Vector2.ONE - dbg.position
			dbg.get_node("ExtensionEndPoint").position = \
				segment_ext.get_end_point() - Vector2.ONE - dbg.position
	
	# Position the end exit at the tip of the last extension.
	var pipe_exit: Variant = segment_inst[-1]
	
	if pipe_exit and last_piece:
		pipe_exit.direction = segments[-1].direction
		pipe_exit.position = last_piece.get_end_point()


## When a segment's direction changes, rotates all subsequent segments by the same
## clockwise delta to preserve the overall pipe shape.
func _segment_direction_changed(idx: int) -> void:
	var main_segment: PipeSegment = segments[idx]
	
	for i: int in range(idx + 1, segments.size()):
		segments[i].direction_updated.disconnect(_segment_direction_changed)
	
	if idx == 0:
		var steps: int = get_direction_steps_with_end(main_segment.old_direction, main_segment.direction)
		
		for i: int in range(idx + 1, segments.size()):
			segments[i].direction = get_direction_end_with_steps(segments[i].direction, steps)
			
			for available_directions: Array in [["Left", "Right"], ["Up", "Down"]]:
				if segments[i].direction in available_directions:
					segments[i].available_directions = available_directions
	elif idx + 1 < segments.size():
		for i: int in range(idx + 1, segments.size()):
			if ((
				main_segment.direction in ["Left", "Right"] and 
				segments[i].direction in ["Left", "Right"]) or (
				
				main_segment.direction in ["Up", "Down"] and 
				segments[i].direction in ["Up", "Down"]
				)):
					segments[i].direction = opposite_direction.get(segments[i].direction)
	
	for i: int in range(idx + 1, segments.size()):
		segments[i].direction_updated.connect(_segment_direction_changed.bind(i))
	
	_build_pipe()
