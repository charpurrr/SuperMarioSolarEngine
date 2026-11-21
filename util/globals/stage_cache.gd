@tool
extends Node

signal started
signal rolled_back

signal checkpoint_reached(uuid: String)

signal marked(category: StringName, uuid: String)

const TRACK_POLICIES = preload("uid://c68ndkvwk2tec")

var stage: StageData
var current_area: StringName

var spawn_id: String = ""
var checkpoint_uuid: String = ""
var checkpoint_area: StringName

## KEY: Object category
## VALUE: {String UUID: bool is_committed}
var _committed: Dictionary[String, Dictionary] = {}
var _pending: Dictionary = {}
var _previously_owned: Dictionary = {}


func begin(data: StageData, profile_record: StageRecord) -> void:
	stage = data

	checkpoint_uuid = ""
	checkpoint_area = &""

	_committed.clear()
	_pending.clear()
	_previously_owned = profile_record.owned_by_category()

	started.emit()


func has(category: StringName, uuid: String) -> bool:
	return _committed.get(category, {}).has(uuid) or _pending.get(category, {}).has(uuid)


func was_collected_before(category: StringName, uuid: String) -> bool:
	return _previously_owned.get(category, {}).has(uuid)


func mark(category: StringName, uuid: String) -> void:
	var layer: Dictionary

	for policy: TrackPolicy in TRACK_POLICIES.policies:
		if policy.category == category:
			layer = _pending if policy.rolls_back else _committed

	layer.get_or_add(category, {})[uuid] = true
	marked.emit(category, uuid)


func count(category: StringName) -> int:
	return _committed.get(category, {}).size() + _pending.get(category, {}).size()


func has_checkpoint() -> bool:
	return not checkpoint_uuid.is_empty()


func reach_checkpoint(uuid: String, area: StringName) -> void:
	commit_pending()

	checkpoint_uuid = uuid
	checkpoint_area = area

	checkpoint_reached.emit(uuid)


func commit_pending() -> void:
	for category: StringName in _pending:
		_committed.get_or_add(category, {}).merge(_pending[category])

	_pending.clear()


func on_death() -> void:
	_pending.clear()

	rolled_back.emit()


func results() -> Dictionary:
	var out: Dictionary = {}

	for category: StringName in _committed:
		for policy: TrackPolicy in TRACK_POLICIES.policies:
			if policy.persists:
				out[category] = _committed[category].keys()

	return out
