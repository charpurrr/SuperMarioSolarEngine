class_name SimplePropertyDisplayData
extends PropertyDisplayData
## [PropertyDisplayData] that uses a single node with a script for the display.

## Script used for the display.
@export var root_script: Script


func add_to(target: Node) -> PropertyDisplay:
	var inst = root_script.new()
	target.add_child(inst)
	return inst
