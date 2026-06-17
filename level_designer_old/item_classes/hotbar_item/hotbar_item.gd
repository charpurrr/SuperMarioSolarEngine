class_name HotbarItem
extends Button
## Hotbar button for an item.

## How fast the progress bar for pinning an item fills up (in seconds.)
@export var pin_hold_time: float
## How fast the progress bar for pinning an item empties out (in seconds.)
@export var pin_release_time: float

@export_category(&"References")
## The icon for this item.
@export var item_icon: TextureRect
## The progress bar for pinning this item.
@export var pin_progress: ProgressBar
## The pin icon that appears when the item is pinned.
@export var pin_icon: Sprite2D

## The [EditorItemData] stored in this slot.
var item_data: EditorItemData

## Whether or not this slot is currently selected.
var selected: bool

## Whether or not this item is pinned.
var pinned: bool

## Stored tween for the pin progress bar.
var tween = null

## Reference to the parent hotbar.
@onready var hotbar: Hotbar = get_parent()
## Reference to the toolbar.
@onready var toolbar: Toolbar = %ToolbarContainer


func _notification(what):
	if what == NOTIFICATION_DRAG_END and not item_icon.visible:
		if get_viewport().gui_is_drag_successful():
			_clear()
		else:
			item_icon.visible = true

	if what == NOTIFICATION_MOUSE_EXIT:
		_tween_decrease()

	if what == NOTIFICATION_FOCUS_EXIT:
		selected = false


func _get_drag_data(_at_position):
	if pinned:
		return
	if item_data == null:
		return null

	hotbar.swapping_item = self

	_tween_decrease()

	var preview_texture := TextureRect.new()

	preview_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_texture.texture = item_data.icon_texture
	preview_texture.size = item_icon.size * 0.7

	preview_texture.position = -preview_texture.size / 2

	var preview := Control.new()

	preview.add_child(preview_texture)

	set_drag_preview(preview)
	item_icon.visible = false

	return item_data


func _can_drop_data(_at_position, data):
	return data is EditorItemData and not pinned


func _drop_data(_at_position, data):
	if item_icon.texture and item_data:
		hotbar.give_swap_data(item_data)
		hotbar.swapping_item = null
		store_item(data)
	else:
		store_item(data)


func _gui_input(event):
	if event.is_action_pressed("e_clear_hotbar_item"):
		_clear()

	if selected:
		if event.is_action_pressed("e_pin_hotbar_item"):
			_tween_inrease()

		if event.is_action_released("e_pin_hotbar_item"):
			_tween_decrease()


## Store an [EditorItemData] in this slot.
func store_item(data: EditorItemData):
	item_icon.texture = data.icon_texture

	# Apply half-pixel offset to ensure the texture is on an integer position.
	var tex_size = data.icon_texture.get_size()
	var tex_offset = tex_size.posmod(2.0) * 0.5
	item_icon.offset_left = tex_offset.x
	item_icon.offset_top = tex_offset.y

	item_icon.visible = true
	item_data = data


func _tween_inrease():
	if tween != null:
		tween.kill()

	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(pin_progress, "value", 100.0, pin_hold_time)
	tween.connect(&"finished", _pin_unpin_item)


func _tween_decrease():
	if tween != null:
		tween.kill()

	tween = get_tree().create_tween()
	tween.tween_property(pin_progress, "value", 0.0, pin_release_time)


func _pin_unpin_item():
	tween.kill()
	pin_progress.value = 0

	pinned = !pinned
	pin_icon.visible = pinned

	if pinned == true:
		hotbar.pin_item(self)
	else:
		hotbar.unpin_item(self)


## Clear this slot, removing stored data and texture.
func _clear():
	if pinned:
		return

	item_icon.texture = null
	item_data = null


func _on_pressed():
	if item_data == null:
		return

	hotbar.editor.level_preview.new_brush(item_data)
	toolbar.drop_tools()

	selected = true
