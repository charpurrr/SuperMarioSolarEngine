class_name StageRecord
extends RefCounted

## KEY: Category name
## VALUE: Array[String] - List of collected objects' UUIDs
var owned: Dictionary = {}
## Maximum amount of [Coin]s grabbed in a [Stage].
var best_score: int = 0


func owned_by_category() -> Dictionary:
	var out: Dictionary = {}

	for category: StringName in owned:
		var collection: Dictionary = {}

		for uuid: String in owned[category]:
			collection[uuid] = true

		out[category] = collection

	return out


## Union only: progress is never removed by a clear.
func merge(results: Dictionary) -> void:
	for category: StringName in results:
		var list: Array = owned.get_or_add(category, [])

		for uuid: String in results[category]:
			if uuid not in list:
				list.append(uuid)


## Removes UUIDs/categories that are no longer in the manifest.
## Returns [code]true[/code] if anything changed.
func prune(data: StageData) -> bool:
	var changed: bool = false
 
	for category: StringName in owned.keys():
		if not data.tracked.has(category):
			owned.erase(category)
			changed = true
			continue
 
		var valid: Array = data.tracked[category]
		var kept: Array = owned[category].filter(func(uuid: String) -> bool: return uuid in valid)
 
		if kept.size() != owned[category].size():
			owned[category] = kept
			changed = true
 
	return changed


func to_dict() -> Dictionary:
	var owned_out: Dictionary = {}

	for category: StringName in owned:
		owned_out[String(category)] = owned[category]

	return {
		"owned": owned_out,
		"best_score": best_score,
	}


static func from_dict(dictionary: Dictionary) -> StageRecord:
	var record: StageRecord = StageRecord.new()

	record.cleared = bool(dictionary.get("cleared", false))
	record.best_score = int(dictionary.get("best_score", 0))
 
	var owned_in: Dictionary = dictionary.get("owned", {})

	for key: String in owned_in:
		var list: Array = []

		for uuid: Variant in owned_in[key]:
			list.append(str(uuid))

		record.owned[StringName(key)] = list

	return record
