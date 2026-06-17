class_name PolygonTool
extends Tool
## Drawing and creating polygons.

@export var terrain_editor: PackedScene
var terrain_editor_node: Line2D


func _on_activate():
	terrain_editor_node = terrain_editor.instantiate()
	owner.add_child(terrain_editor_node)


func _on_deactivate():
	owner.remove_child(terrain_editor_node)
