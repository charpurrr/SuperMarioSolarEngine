@tool
@abstract
class_name PreviewDisplayData
extends Resource
## Abstract class - do NOT instance! Stores data about a preview item display node.
##
## Stores data about a preview item display node,
## allowing it to be created and added to a [PreviewItem].
## A display node is a node used to display the item in the editor,
## such as a Sprite2D with a texture.


## Creates an instance of the preview display.
@abstract
func create() -> Node2D


## Returns the selection shape of the preview display.
func get_selection_shape() -> Shape2D:
	return null


## Sets the selection shape of the preview display to a given shape.
func set_selection_shape(_shape: Shape2D) -> void:
	pass


## Returns [code]true[/code] if the preview display requires a static selection shape.
func needs_static_selection_shape() -> bool:
	return false


## Returns the reference texture for the display.
## This is the primary texture used to generate a selection shape.
func get_reference_texture() -> Texture2D:
	return null
