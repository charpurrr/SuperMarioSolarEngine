@tool
extends Control

@export var max_count: int:
	set(val):
		max_count = clamp(val, 0, 999)

		if is_instance_valid(label):
			_update_label(false)

@export var coin_count: int:
	set(val):
		coin_count = clamp(val, 0, max_count)

		if is_instance_valid(label):
			_update_label(true)

@export_custom(PROPERTY_HINT_NONE, "suffix:px") var bounce_height: int = 3
@export var bounce_color: Color = Color.RED

@export_category("References")
@export var label: Label

var call_count: int = 0

var init_pos_y: float = 0.0


func _ready() -> void:
	# This signal gets added to the root in the main coin counter.
	get_tree().connect(&"coin_collected", _increment)

	max_count = Coin.total_reds

	init_pos_y = label.position.y


func _increment(type: Coin.Type):
	if not type == Coin.Type.RED: return

	coin_count += 1


func _update_label(do_animation: bool) -> void:
	label.text = "%d/%d" % [coin_count, max_count] 

	# The logic underneath this return is purely for the bounce and color modulate animation.
	if not do_animation: return

	label.position.y -= bounce_height
	label.modulate = bounce_color

	call_count += 1

	while (label.position.y != 0 or label.modulate != Color.WHITE) and call_count == 1:
		var delta: float = get_process_delta_time()
		label.position.y = Math.lerp_fr(label.position.y, init_pos_y, 15 * delta, 0.01)
		label.modulate = Math.lerp_colr(label.modulate, Color.WHITE, 5 * delta, 0.01)
		await Engine.get_main_loop().process_frame

	call_count -= 1
