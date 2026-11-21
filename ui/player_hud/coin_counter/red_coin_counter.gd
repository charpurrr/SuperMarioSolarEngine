@tool
extends Control

## Editor preview only.
@export var max_count: int:
	set(val):
		max_count = clamp(val, 0, 999)

		if is_instance_valid(label):
			_update_label()

			if Engine.is_editor_hint():
				_animate_label()

## Editor preview only.
@export var coin_count: int:
	set(val):
		coin_count = clamp(val, 0, max_count)

		if is_instance_valid(label):
			_update_label()

			# In game the bounce is triggered by pickups, not by the value changing.
			if Engine.is_editor_hint():
				_animate_label()

@export_custom(PROPERTY_HINT_NONE, "suffix:px") var bounce_height: int = 3
@export var bounce_color: Color = Color.RED

@export_group("Meta")
@export var label: Label

var call_count: int = 0
var init_pos_y: float = 0.0


func _ready() -> void:
	if Engine.is_editor_hint(): return

	init_pos_y = label.position.y

	StageCache.marked.connect(_on_marked)
	StageCache.started.connect(_sync_from_session)
	StageCache.rolled_back.connect(_sync_from_session)

	_sync_from_session()


func _on_marked(marked_category: StringName, _uuid: String) -> void:
	if marked_category == &"red_coins":
		coin_count += 1
		_update_label()
		_animate_label()


## Pulls the total from the baked manifest and the current count from the session.
## Sets the values without any bounce.
func _sync_from_session() -> void:
	if StageCache.stage == null:
		return

	max_count = StageCache.stage.total(&"red_coins")
	coin_count = StageCache.count(&"red_coins")

	# Hides the counter in stages that don't contain red coins.
	visible = max_count > 0


func _update_label() -> void:
	label.text = "%d/%d" % [coin_count, max_count] 


func _animate_label() -> void:
	label.position.y -= bounce_height
	label.modulate = bounce_color

	call_count += 1

	while (label.position.y != 0 or label.modulate != Color.WHITE) and call_count == 1:
		var delta: float = get_process_delta_time()
		label.position.y = Math.lerp_fr(label.position.y, init_pos_y, 15 * delta, 0.01)
		label.modulate = Math.lerp_colr(label.modulate, Color.WHITE, 5 * delta, 0.01)
		await Engine.get_main_loop().process_frame

	call_count -= 1
