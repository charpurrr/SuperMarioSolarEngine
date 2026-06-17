class_name Hotbar
extends HFlowContainer
## The level designer hotbar.

## Reference to the parent [LevelEditor].
@export var editor: LevelEditor

## List of pinned [HotbarItem]s.
var pinned_items: Array = []

## Current [HotbarItem] held to be swapped.
var swapping_item: HotbarItem


## Add an [EditorItemData] to a [HotbarItem] slot.
func add_item(item_data: EditorItemData):
	var last_slot: HotbarItem = null
	var slots: Array[Node] = get_children()

	slots.reverse()

	var skipped_pins: Array = []

	for slot in slots:
		if slot in pinned_items:
			skipped_pins.append(slot)
		else:
			last_slot = slot
			break

	if last_slot == null:
		return

	last_slot.store_item(item_data)

	move_child(last_slot, 0)

	for item in get_children():
		if item in pinned_items and item not in skipped_pins:
			move_child(item, item.get_index() - 1)


## Pin an item so that it doesn't change slot.
func pin_item(item: HotbarItem):
	pinned_items.append(item)


## Unpin an item.
func unpin_item(item: HotbarItem):
	pinned_items.erase(item)


## Swap data into the pending swap slot.
func give_swap_data(item_data: EditorItemData):
	if swapping_item:
		swapping_item.store_item(item_data)
