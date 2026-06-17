class_name Property
extends Resource
## A property of an [EditorItemData].

## Name of the property. Corresponds with a variable name on the spawned item.
@export var name: StringName

## Whether or not this property will display in the in-game property list.
@export var show_in_properties: bool = false

## Data type of the property.
@export var data_type: Variant.Type

## [PropertyDisplayData] that handles displaying this property.
@export var display_data: PropertyDisplayData

## The [InspectorEntry] associated with this property.
@export var inspector_entry: PackedScene

## The default value for this property.
@export var default: Array
