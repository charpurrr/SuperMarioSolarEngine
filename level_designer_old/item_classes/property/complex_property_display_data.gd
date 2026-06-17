class_name ComplexPropertyDisplayData
extends PropertyDisplayData
## [PropertyDisplayData] that uses a scene for the display.

## Scene used to display the property.
@export var scene: PackedScene


func add_to(target: Node) -> PropertyDisplay:
	var inst = scene.instantiate()
	target.add_child(inst)
	return inst
