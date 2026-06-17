@abstract
class_name PropertyDisplayData
extends Resource
## Stores data about a [PropertyDisplay], and provides methods for adding it to a preview display.

## Creates the [PropertyDisplay] and adds it as a child of the target.
## Returns the [PropertyDisplay] node that was created.
## Should be overridden by child classes.
@abstract
func add_to(_target: Node) -> PropertyDisplay
