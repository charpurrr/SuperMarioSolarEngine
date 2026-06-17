@tool
class_name DraggableButton
extends Control
## An editor widget button that can be used for numerous actions.

## Emitted when the cursor clicks on this button.
signal selected(button: DraggableButton)
## Emitted when the cursor releases their click on this button.
signal deselected(button: DraggableButton)
## Emitted when the user tries to delete this button.
## Use this to create custom deletion logic depending on the widget's purpose.
signal delete_attempted

@export var button: TextureButton
@export var x_lock: TextureRect
@export var y_lock: TextureRect

@export_category(&"Visuals")
@export_enum("Yellow", "Red", "Blue", "Hologram") var costume: String = "Yellow":
	set(value):
		costume = value

		# Check for the blue costume data because it is loaded last.
		if is_instance_valid(blue_costume_data):
			_set_appropriate_textures()

@export var hologram_costume_data: ButtonCostume
@export var yellow_costume_data: ButtonCostume
@export var red_costume_data: ButtonCostume
@export var blue_costume_data: ButtonCostume

@export_category(&"Behaviour")
## Locks the axis of this draggable button so it can only move on the x-axis.[br][br]
## [i]Note that the rotation of its parent defines the axis, not the global world.[/i]
@export var axis_lock_x: bool = false:
	set(value):
		axis_lock_x = value
		if is_instance_valid(x_lock): # To avoid reference issues on the first run of code
			x_lock.visible = value
## Locks the axis of this draggable button so it can only move on the y-axis.[br][br]
## [i]Note that the rotation of its parent defines the axis, not the global world.[/i]
@export var axis_lock_y: bool = false:
	set(value):
		axis_lock_y = value
		if is_instance_valid(y_lock): # To avoid reference issues on the first run of code
			y_lock.visible = value
## Whether or not the button can be dragged around.
@export var draggable: bool = true

var held_down: bool
var hovered_over: bool


func _ready() -> void:
	# To make sure the graphics for the X and Y locks are shown 
	# properly on the first run of the code
	x_lock.visible = axis_lock_x
	y_lock.visible = axis_lock_y


func _input(_event: InputEvent) -> void:
	if draggable and held_down:
		if axis_lock_x:
			global_position.x = get_global_mouse_position().x
		elif axis_lock_y:
			global_position.y = get_global_mouse_position().y
		else:
			global_position = get_global_mouse_position()
	elif hovered_over and Input.is_action_just_pressed("e_delete"):
		# Delete behaviour can be defined by whatever class is using this widget.
		# (If any behaviour should apply at all.)
		delete_attempted.emit()


func _set_appropriate_textures() -> void:
	match costume:
		"Yellow":
			button.texture_normal = yellow_costume_data.normal_graphic
			button.texture_hover = yellow_costume_data.hover_graphic
			button.texture_pressed = yellow_costume_data.pressed_graphic
		"Red":
			button.texture_normal = red_costume_data.normal_graphic
			button.texture_hover = red_costume_data.hover_graphic
			button.texture_pressed = red_costume_data.pressed_graphic
		"Blue":
			button.texture_normal = blue_costume_data.normal_graphic
			button.texture_hover = blue_costume_data.hover_graphic
			button.texture_pressed = blue_costume_data.pressed_graphic
		"Hologram":
			button.texture_normal = hologram_costume_data.normal_graphic
			button.texture_hover = hologram_costume_data.hover_graphic
			button.texture_pressed = hologram_costume_data.pressed_graphic


func _on_button_button_down() -> void:
	selected.emit(self)
	held_down = true


func _on_button_button_up() -> void:
	deselected.emit(self)
	held_down = false


func _on_button_mouse_entered() -> void:
	hovered_over = true
	grab_focus()


func _on_button_mouse_exited() -> void:
	hovered_over = false
	release_focus()
