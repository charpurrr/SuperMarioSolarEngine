@tool
class_name PipeSegment
extends Resource
## A single segment of a [WarpPipe], representing
## one directional run of pipe.

## Emitted when [member direction] changes. Used by [WarpPipe] to propagate
## smart rotation to subsequent segments.
signal direction_updated
## Emitted when any property changes that requires the pipe to be rebuilt.
signal updated

## The direction this segment points toward.
## Constrained to [member available_directions] which is set via [WarpPipe].
@export_enum("Left", "Down", "Up", "Right") var direction: String:
	set(val):
		if val.is_empty() or val == direction: return

		old_direction = direction
		direction = val

		direction_updated.emit()

		notify_property_list_changed()

## The length of this segment.
@export_range(0, 0, 1.0, "hide_control", "or_greater", "suffix:px")
var length: float:
	set(val):
		length = val
		updated.emit()

@export var is_block: bool:
	set(val):
		is_block = val
		updated.emit()

## The index of this segment within the [WarpPipe]'s [member WarpPipe.segments] array.
var idx: int

## Whether this segment is a connector segment (i.e. not the first segment).
## Controls visibility of [member is_block] in the inspector.
var is_connector: bool = true
## The direction this segment had before the most recent [member direction] change.
## Used by [WarpPipe] to calculate rotation steps for smart propagation.
var old_direction: String

## The directions this segment is allowed to point, based on the previous segment's direction.
## Setting this will reassign [member direction] to the first available option if the
## current direction is no longer valid.
var available_directions: PackedStringArray:
	set(val):
		available_directions = val

		if direction not in val:
			direction = val[0]

		notify_property_list_changed()


func _validate_property(property: Dictionary) -> void:
	if property.name == "direction":
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = ",".join(available_directions)

	if property.name == "is_block" and not is_connector:
		property.usage = PROPERTY_USAGE_NONE
