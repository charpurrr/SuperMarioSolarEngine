class_name Toolbar
extends PanelContainer
## Holds data for the currently active tool.

@export var editor: LevelEditor

@export_category(&"Local References")
@export var select: SelectTool
@export var pen: Tool
@export var erase: Tool
@export var eyedrop: Tool
@export var shape: Tool
@export var gravity: Tool

var active_tool: Tool


func _ready():
	editor.user_interface.preview_detector.hover_updated.connect(_update_mouse_icon)
	update_active_tool(select)


func _update_mouse_icon():
	if active_tool != null and editor.cursor_in_preview_field():
		Input.set_custom_mouse_cursor(
			active_tool.mouse_icon, active_tool.mouse_shape, active_tool.hotspot
		)
	else:
		Util.set_cursor_to_default()


func update_active_tool(new_tool: Tool):
	editor.level_preview.cancel_brush()

	if active_tool != null:
		active_tool.deactivate()
	new_tool.activate()

	active_tool = new_tool


func drop_tools():
	if active_tool == null:
		return

	active_tool.deactivate()
	active_tool = null

	Util.set_cursor_to_default()
