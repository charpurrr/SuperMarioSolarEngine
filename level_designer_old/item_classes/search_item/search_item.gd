class_name SearchItem
extends Button
## An item within the search item menu.

## [EditorItemData] stored in this slot.
var item_data: EditorItemData

## Set by the item search menu upon creation.
var hotbar: Hotbar

@onready var item_icon = $ItemIcon


func create_item(data: EditorItemData):
	item_icon.texture = data.icon_texture
	
	# Apply half-pixel offset to ensure the texture is on an integer position.
	var tex_size = data.icon_texture.get_size()
	var tex_offset = tex_size.posmod(2.0) * 0.5
	item_icon.offset_left = tex_offset.x
	item_icon.offset_top = tex_offset.y
	
	item_data = data


func _get_drag_data(_at_position):
	var preview_texture := TextureRect.new()

	preview_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_texture.texture = item_data.icon_texture
	preview_texture.size = item_icon.size * 1.2

	preview_texture.position = -preview_texture.size / 2

	var preview := Control.new()

	preview.add_child(preview_texture)

	set_drag_preview(preview)

	return item_data


func _on_button_up():
	hotbar.add_item(item_data)
