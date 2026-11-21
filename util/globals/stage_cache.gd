@tool
extends Node

signal started
signal rolled_back

@warning_ignore("unused_signal")
signal area_loaded
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
var committed: Dictionary[String, Dictionary] = {}
var pending: Dictionary = {}
var previously_owned: Dictionary = {}


func begin(data: StageData, profile_record: StageRecord) -> void:
	stage = data

	checkpoint_uuid = ""
	checkpoint_area = &""

	committed.clear()
	pending.clear()
	previously_owned = profile_record.owned_by_category()

	started.emit()


func has(category: StringName, uuid: String) -> bool:
	return committed.get(category, {}).has(uuid) or pending.get(category, {}).has(uuid)


func was_collected_before(category: StringName, uuid: String) -> bool:
	return previously_owned.get(category, {}).has(uuid)


func mark(category: StringName, uuid: String) -> void:
	var layer: Dictionary

	for policy: TrackPolicy in TRACK_POLICIES.policies:
		if policy.category == category:
			layer = pending if policy.rolls_back else committed

	layer.get_or_add(category, {})[uuid] = true
	marked.emit(category, uuid)


func count(category: StringName) -> int:
	return committed.get(category, {}).size() + pending.get(category, {}).size()


func has_checkpoint() -> bool:
	return not checkpoint_uuid.is_empty()


func reach_checkpoint(uuid: String, area: StringName) -> void:
	commit_pending()

	checkpoint_uuid = uuid
	checkpoint_area = area

	checkpoint_reached.emit(uuid)


func commit_pending() -> void:
	for category: StringName in pending:
		committed.get_or_add(category, {}).merge(pending[category])

	pending.clear()


func on_death() -> void:
	pending.clear()

	rolled_back.emit()


func results() -> Dictionary:
	var out: Dictionary = {}

	for category: StringName in committed:
		for policy: TrackPolicy in TRACK_POLICIES.policies:
			if policy.persists:
				out[category] = committed[category].keys()

	return out
