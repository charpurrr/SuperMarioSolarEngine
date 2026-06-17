@abstract
class_name PropertyDisplay
extends Node2D
## Handles the display of properties in the editor.

## The preview display this property affects.
var preview_display: Node2D

## The [PreviewItem] this property affects.
var preview_item: PreviewItem

## Abstract method. Sets the value of the property to a new value.
@abstract
func set_value(_new_value: Variant) -> void
