class_name InspectorEntry
extends HBoxContainer
## An editable entry in the level editor's inspector.
##
## An editable entry in the level editor's inspector.
## Changing the value of this entry will update the associated property in all selected items.

## Emitted when the value of this entry is changed.
signal value_changed(value: Variant)

## The label for this entry. Displays the name of the associated property.
@export var label: Label


## Sets the text for the property name label.
func set_label(text: String) -> void:
	label.text = text


## Sets the associated property value for this entry.
func set_value(_value: Variant) -> void:
	assert(false, "Missing set_value definition for %s." % name)


## Called when the value of a child element changes.
## E.g. A child SpinBox' value changes from 1 to 2.
func _on_child_value_changed(value: Variant) -> void:
	value_changed.emit(value)
