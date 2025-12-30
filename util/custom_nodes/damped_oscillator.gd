@icon("res://util/custom_nodes/damped_oscillator.svg")
@tool
class_name DampedOscillator
extends Node2D

## How much the spring jiggles.
@export var jiggle: float = 0.2
## How quickly the spring returns to 0.
@export var damping: float = 0.15

## If true, runs in [method Node._physics_process], otherwise runs in [method Node._process].
@export var process_in_physics: bool = false

@export_category(&"Debugging")
@export var preview_power: float = 20.0
@export_tool_button("Preview", "Play")
var preview_action: Callable = _preview

var debug_draw: bool = false:
	set(val):
		debug_draw = val
		queue_redraw()

var velocity: float = 0.0
var displacement: float = 0.0


func _draw() -> void:
	if debug_draw:
		draw_circle(Vector2(0, displacement), 2.0, Color.WHITE)


func _process(_delta: float) -> void:	
	if not process_in_physics:
		_adaptive_process()


func _physics_process(_delta: float) -> void:
	if process_in_physics:
		_adaptive_process()


## Process mode that runs either in generic, or physics process mode,
## depending on the value of [member process_in_physics].
func _adaptive_process() -> void:
	if debug_draw:
		queue_redraw()

	if not is_zero_approx(velocity):
		_update()
	else:
		velocity = 0
		displacement = 0

		debug_draw = false


func _preview() -> void:
	debug_draw = true
	start(preview_power)


func start(power: float) -> void:
	velocity = power


func _update() -> void:
	# F = -kx | k = jiggle, x = displacement
	var force: float = (-jiggle * displacement) + (damping * velocity)
	# Since we're assuming mass to be 1 here we can just subtract
	# the force as we would an acceleration.
	velocity -= force
	displacement -= velocity
