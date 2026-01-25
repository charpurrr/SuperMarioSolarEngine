class_name WindowSizer

const MAX_SCALE: int = 3

static var default_size = Vector2(
	ProjectSettings.get_setting("display/window/size/viewport_width"),
	ProjectSettings.get_setting("display/window/size/viewport_height")
)

## The last window scale value that wasn't a fullscreen.[br]
## Useful for reverting back to a window scale when toggling fullscreen
## using the hotkey.
static var last_none_fs: int = 1


static func set_win_scale(new_scale):
	var screen: int = DisplayServer.window_get_current_screen()
	var screen_size: Vector2i = DisplayServer.screen_get_size(screen)
	var window_size: Vector2i = default_size * (new_scale + 1)

	# Set fullscreen if a window scale exceeds the bounds of the screen.
	if window_size > screen_size:
		new_scale = MAX_SCALE

	if new_scale != MAX_SCALE:
		last_none_fs = new_scale

		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(window_size)
	
		var screen_top_left: Vector2i = DisplayServer.screen_get_position(screen)

		# On multi-monitor setups, the screen position is relative to the virtual desktop area.
		# On multi-monitor setups with different screen resolutions or orientations,
		# the origin may be located outside any display like this:
		#
		# * (0, 0)        +-------+
		#                 |       |
		# +-------------+ |       |
		# |             | |       |
		# |             | |       |
		# +-------------+ +-------+

		var window_pos: Vector2i = screen_top_left + (screen_size - window_size) / 2
		DisplayServer.window_set_position(window_pos)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


## Sets the [code]VIEWPORT_SIZE[/code] global shader parameter.
## This should be connected to the [signal Viewport.size_changed] signal.
static func set_global_shader_size(new_resolution: Vector2):
	RenderingServer.global_shader_parameter_set("VIEWPORT_SIZE", new_resolution)
