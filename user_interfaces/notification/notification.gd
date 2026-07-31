class_name Notification
extends Control
## Pop-up notifications, warnings, or errors.

@onready var sprite: AnimatedSprite2D = $Panel
@onready var label: Label = %Label

## Type of notification. (I.e. error, warning, push)
var type: StringName
## What the notification should say.
var input: String


func _ready():
	sprite.animation = type
	label.text = input


func _on_animation_player_animation_finished(_anim_name):
	queue_free()
