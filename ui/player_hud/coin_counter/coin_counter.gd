@tool
extends Control

## How much each coin category is worth.
const COIN_VALUES: Dictionary[StringName, int] = {
	&"coins": 1,
	&"blue_coins": 5,
	&"red_coins": 2,
}

const COIN_COLORS: Dictionary[StringName, Color] = {
	&"coins": Color(0xffc800ff),
	&"blue_coins": Color(0x0034ffff),
	&"red_coins": Color(0xff0000ff),
}

## Editor preview only. In game this is always derived from [StageCache].
@export var coin_count: int:
	set(val):
		coin_count = clampi(val, 0, 999)

		if is_instance_valid(label):
			_update_label()

			# In game the bounce is triggered by pickups, not by the value changing.
			if Engine.is_editor_hint():
				_animate_label()

@export_custom(PROPERTY_HINT_NONE, "suffix:px") var bounce_height: int = 3
@export var bounce_color: Color = Color.YELLOW

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
	if not COIN_VALUES.has(marked_category):
		return

	bounce_color = COIN_COLORS[marked_category]
	coin_count = _session_total()

	_animate_label()


## Sets the count from the session without any bounce.
func _sync_from_session() -> void:
	if StageCache.stage == null:
		return

	coin_count = _session_total()


## Committed + pending coins, weighted by value.
func _session_total() -> int:
	var total: int = 0

	for category: StringName in COIN_VALUES:
		total += StageCache.count(category) * COIN_VALUES[category]

	return total


func _update_label() -> void:
	label.text = str(coin_count).pad_zeros(3)


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
