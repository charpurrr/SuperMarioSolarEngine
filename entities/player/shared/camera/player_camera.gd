class_name PlayerCamera
extends Camera2D

@export var zoom_in_sfx: SFXLayer
@export var zoom_out_sfx: SFXLayer

@export var zoom_max: float = 200
@export var zoom_min: float = 50

@export var zoom_follow_speed: float = 5.0

@export_category(&"Velocity Panning Variables")
## How much the velocity that's added to the position is multiplied by.
@export var velocity_pan_factor: float = 8.0

@export var pan_follow_speed: float = 2.0

@export_category(&"References")
@export var shake_x_spring: DampedOscillator
@export var shake_y_spring: DampedOscillator

## This is set in [WorldMachine].
@onready var player: Player

## The current camera zoom in percentage.
## (Note: higher zoom percentage means you can see more level.)
var zoom_percentage: float = 100

## The zoom value the camera gets tweened to.
var target_zoom: float = 100

## Current position (relative to the player) of the camera set by the velocity.
var velocity_offset: Vector2 = Vector2.ZERO

var base_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	base_offset = offset


func _physics_process(delta: float) -> void:
	zoom_percentage = lerp(zoom_percentage, 
		target_zoom,
		Math.interp_weight_idp(zoom_follow_speed, delta)
	)

	var zoom_factor: float = 1 / (zoom_percentage / 100)

	zoom = Vector2(zoom_factor, zoom_factor)

	velocity_offset = velocity_offset.lerp(
		player.velocity * delta * velocity_pan_factor,
		Math.interp_weight_idp(pan_follow_speed, delta)
	)

	position = velocity_offset
	offset = base_offset + Vector2(shake_x_spring.displacement, shake_y_spring.displacement)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"camera_zoom_in"):
		if target_zoom != zoom_min:
			zoom_in_sfx.play_sfx_at(self)

		if target_zoom <= 100:
			target_zoom -= 25
		else:
			target_zoom -= 50

	if event.is_action_pressed(&"camera_zoom_out"):
		if target_zoom != zoom_max:
			zoom_out_sfx.play_sfx_at(self)

		if target_zoom < 100:
			target_zoom += 25
		else:
			target_zoom += 50

	target_zoom = clamp(target_zoom, zoom_min, zoom_max)


func shake(power: Vector2) -> void:
	shake_x_spring.start(power.x)
	shake_y_spring.start(power.y)
