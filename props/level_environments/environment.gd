class_name LevelEnvironment
extends CanvasLayer

## The gradient map used for the [PauseMenu]'s color blur.
@export var pause_gradient_map: GradientTexture1D
@export var foreground_spotlights := false:
	set(val):
		foreground_spotlights = val
		GameState.spotlights_enabled = val

var camera: Camera2D
