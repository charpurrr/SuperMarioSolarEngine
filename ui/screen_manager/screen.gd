@abstract
class_name Screen
extends Control
## Abstract class for a screen that gets handled by a screen manager.

## The sound effect that plays when this screen is transitioned to.
@export var open_sfx: SoundEffect
## The sound effect that plays when this screen is transitioned to.
@export var close_sfx: SoundEffect
## The name of the menu opening animation as seen in the screen manager's AnimationPlayer.
@export var open_anim: StringName
## The name of the menu opening animation as seen in the screen manager's AnimationPlayer. [br][br]
## Note: You can choose to simply play the opening animation backwards by entering « BACKWARDS »
## in all caps in this field.
@export var close_anim: StringName
## Which node grabs focus when this screen is opened.
@export var focus_grabber: Control

## Whether or not this screen is enabled.
var enabled: bool = false

## Set by the screen manager node.
var manager: ScreenManager
var ui: UserInterface


## Ran as soon as this screen starts being transitioned to.
## (Does not wait for the transition animation to finish first.)
func on_load() -> void:
	pass


## Ran once when this screen has been transitioned to.
## (Waits for the transition animation to finish first.)
func on_enter() -> void:
	pass


## Ran once when this screen starts being transitioned from.
## (Does not wait for the transition animation to finish first.)
func on_exit() -> void:
	pass


## Ran once when this screen has been transitioned from.
## (Waits for the transition animation to finish first.)
func on_gone() -> void:
	pass
