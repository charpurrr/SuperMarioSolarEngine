class_name Tool
extends Button
## Editor tool.

@export var toolbar: Toolbar
## The visual icon of the tool.
@export var mouse_icon: Texture2D
## The shape of the tool.
@export var mouse_shape: Input.CursorShape
## The hotspot location of the cursor.
## [i]This is the point in the cursor that interacts with other elements on the screen.[/i]
@export var hotspot: Vector2i

## Whether or not the tool is active for use.
var active: bool


func _ready():
	var callable: Callable = toolbar.update_active_tool

	connect(&"pressed", callable.bind(self))


func _process(_delta):
	if active:
		_tick()


## Overridden by the child class.
func _tick():
	pass


## Activates the tool.
func activate():
	active = true
	_on_activate()


## Deactivates the tool.
func deactivate():
	active = false
	_on_deactivate()


## Called when the tool becomes active.
func _on_activate():
	pass


## Called when the tool becomes inactive.
func _on_deactivate():
	pass
