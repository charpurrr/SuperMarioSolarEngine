class_name EditorItemDataTerrain
extends EditorItemData
## Data for a terrain item inside of the Level Editor.
## This needs to be different from other types of items because terrain doesn't utilise scenes.

## The associated TerrainProperties resource, containing the properties of this terrain set.
@export var item_resource: TerrainProperties
