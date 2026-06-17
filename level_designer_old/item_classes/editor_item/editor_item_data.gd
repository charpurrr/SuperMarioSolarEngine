class_name EditorItemData
extends Resource
## Definition for an item inside of the Level Editor.

## Enum of categories to which this item can belong.
enum Category {
	TERRAIN,
	OBJECT,
	DECORATION,
	ENTITY,
	NPC,
	UTILITY,
}

## Preview item scene; can be instanced in order to create a preview of this item.
const PREVIEW_ITEM: PackedScene = preload(
	"res://level_designer/item_classes/preview_item/preview_item.tscn"
)

## Icon texture that represents this item.
@export var icon_texture: Texture2D

## Search category that this item is in.
@export var category: Category

## List of item properties that this item has.
@export var properties: Array[Property]

## [PreviewDisplayData] associated with this item.
@export var preview_display_data: PreviewDisplayData


## Create a [PreviewItem] for this item.
func create_preview() -> PreviewItem:
	var inst = PREVIEW_ITEM.instantiate()
	inst.load_item_data(self)
	return inst
