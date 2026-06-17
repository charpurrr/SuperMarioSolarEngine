class_name EditorItemDataActor
extends EditorItemData
## Data for an actor item inside of the Level Editor.
## This needs to be different from terrain items because actor items utilise scenes.

## The [PackedScene] that is instantiated into the level.
@export var item_scene: PackedScene
