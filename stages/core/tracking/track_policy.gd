class_name TrackPolicy
extends Resource

## The category name of the tracked objects.
@export var category: StringName
## Whether or not this object gets its state rolled back to the previous checkpoint.
@export var rolls_back: bool = false
## Whether or not this object gets written to the save file when the [Stage] is cleared.
@export var persists: bool = false
