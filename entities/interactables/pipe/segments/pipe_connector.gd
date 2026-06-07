@tool
class_name PipeConnector
extends Sprite2D
## A connection piece between two [PipeSegment]s in a [WarpPipe].
##
## Renders as either a straight block or a directional corner, and automatically
## selects the correct texture based on [member entry_dir] and [member exit_dir].

## The type of connector. "Block" renders a straight connection, "Corner" renders
## a turn between two perpendicular directions.
@export_enum("Block", "Corner") var type: String:
	set(val):
		type = val

		_updates()
		notify_property_list_changed()

## The direction this connector is entered from.[br]
## [i]I.e. where the previous [PipeSegment] ended.[/i][br][br]
## [b]Note[/b]: This is set automatically by [method WarpPipe._build_pipe].
@export_enum("Left", "Down", "Up", "Right") var entry_dir: String:
	set(val):
		entry_dir = val

		_updates()
		notify_property_list_changed()

## The direction this connector exits toward.[br]
## [i]I.e. where the next [PipeSegment] begins.[/i][br][br]
## Constrained to the two directions perpendicular to [member entry_dir].
## Driven by the [member PipeSegment.direction] of the associated [PipeSegment].
@export var exit_dir: String:
	set(val):
		exit_dir = val
		_updates()

@export_group("Textures", "texture_")
## Texture used when [member type] is [code]"Block"[/code].
@export var texture_block: Texture2D
## Texture used when [member type] is [code]"Corner"[/code] and the turn goes
## from [code]["Up", "Right"][/code] or [code]["Left", "Down"][/code].[br][br]
## [b]Note:[/b] This has the shape [b]╔[/b].
@export var texture_corner_top_left: Texture2D
## Texture used when [member type] is [code]"Corner"[/code] and the turn goes
## from [code]["Up", "Left"][/code] or [code]["Right", "Down"][/code].[br][br]
## [b]Note:[/b] This has the shape [b]╗[/b].
@export var texture_corner_top_right: Texture2D
## Texture used when [member type] is [code]"Corner"[/code] and the turn goes
## from [code]["Down", "Right"][/code] or [code]["Left", "Up"][/code].[br][br]
## [b]Note:[/b] This has the shape [b]╚[/b].
@export var texture_corner_bottom_left: Texture2D
## Texture used when [member type] is [code]"Corner"[/code] and the turn goes
## from [code]["Down", "Left"][/code] or [code]["Right", "Up"][/code].[br][br]
## [b]Note:[/b] This has the shape [b]╝[/b].
@export var texture_corner_bottom_right: Texture2D


## Returns the world-space point where the next [PipeSegment]'s extension should begin.
func get_end_point() -> Vector2:
	return position + _get_half_size(exit_dir) + offset


## Performs all update functions.
## Updates the available exit directions, and the appropriate visuals.
func _updates() -> void:
	_update_available_exit_dirs()
	_update_visual()


## Updates [member texture] and [member offset] to match the current
## [member type], [member entry_dir], and [member exit_dir].
func _update_visual() -> void:
	offset = _get_half_size(entry_dir)

	if type == "Corner":
		if entry_dir.is_empty() or exit_dir.is_empty(): return
		texture = _get_corner_text()
	else:
		texture = texture_block

## Ensures [member exit_dir] is perpendicular to [member entry_dir],
## correcting it to a valid default if not.
func _update_available_exit_dirs() -> void:
	match entry_dir:
		"Left", "Right":
			if exit_dir not in ["Up", "Down"]:
				exit_dir = "Up"
		"Up", "Down":
			if exit_dir not in ["Left", "Right"]:
				exit_dir = "Left"


## Returns the correct corner texture for the current [member entry_dir]
## and [member exit_dir] combination.
## Emits an error and returns a placeholder if the combination is invalid.
func _get_corner_text() -> Texture2D:
	match [entry_dir, exit_dir]:                 
		["Down", "Left"], ["Right", "Up"]:
			return texture_corner_bottom_right
		["Up", "Right"], ["Left", "Down"]:
			return texture_corner_top_left
		["Up", "Left"], ["Right", "Down"]:
			return texture_corner_top_right
		["Down", "Right"], ["Left", "Up"]:
			return texture_corner_bottom_left
		_:
			push_error(
				"Misconfigured entry_dir and exit_dir combination [%s, %s]." % [entry_dir, exit_dir]
			)
			return PlaceholderTexture2D.new()


## Converts a direction string to its corresponding unit [Vector2].
func _get_direction(dir: String) -> Vector2:
	match dir:
		"Up": return Vector2.UP
		"Down": return Vector2.DOWN
		"Left": return Vector2.LEFT
		"Right", _: return Vector2.RIGHT


## Returns a [Vector2] offset of half the texture's size along [param dir].
## Used to calculate anchor points and end points relative to the connector's center.
## Returns [constant Vector2.ZERO] if no texture is set.
func _get_half_size(dir: String) -> Vector2:
	if not texture: return Vector2.ZERO

	if dir in ["Left", "Right"]:
		return _get_direction(dir) * texture.get_size().x / 2
	else:
		return _get_direction(dir) * texture.get_size().y / 2


func _validate_property(property: Dictionary) -> void:
	if property.name in ["entry_dir", "exit_dir"] and type != "Corner":
		property.usage = PROPERTY_USAGE_NO_EDITOR
		return

	if property.name == "exit_dir":
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = "Up,Down" if entry_dir in ["Left", "Right"] else "Left,Right"
