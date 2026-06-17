class_name ItemSearchMenu
extends Panel
## Search menu for all editor items.

@export var hotbar: HFlowContainer

@export var item_list: EditorItemList
@export var item_slot: PackedScene

@export var catg_terrain: HFlowContainer
@export var catg_object: HFlowContainer
@export var catg_decoration: HFlowContainer
@export var catg_entity: HFlowContainer
@export var catg_npc: HFlowContainer
@export var catg_utility: HFlowContainer

@onready var category_connections: Dictionary[EditorItemData.Category, HFlowContainer] = {
	EditorItemData.Category.TERRAIN: catg_terrain,
	EditorItemData.Category.OBJECT: catg_object,
	EditorItemData.Category.DECORATION: catg_decoration,
	EditorItemData.Category.ENTITY: catg_entity,
	EditorItemData.Category.NPC: catg_npc,
	EditorItemData.Category.UTILITY: catg_utility,
}


func _ready():
	for item in item_list.items:
		var inst: Node = item_slot.instantiate()

		category_connections[item.category].add_child(inst)
		inst.create_item(item)
		inst.hotbar = hotbar
