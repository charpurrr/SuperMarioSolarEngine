class_name Profile
extends RefCounted
## Everything persistent about the save file.
## Plain data, serialized by [SaveManager].

const VERSION: int = 1

var stages: Dictionary[StringName, StageRecord] = {}


func record_for(stage_id: StringName) -> StageRecord:
	if not stages.has(stage_id):
		stages[stage_id] = StageRecord.new()

	return stages[stage_id]


func to_dict() -> Dictionary:
	var stage_dicts: Dictionary = {}

	for stage_id: StringName in stages:
		stage_dicts[stage_id] = stages[stage_id].to_dict()
 
	return {
		"version": VERSION,
		"stages": stage_dicts,
	}


static func from_dict(dictionary: Dictionary) -> Profile:
	var profile: Profile = Profile.new()
 
	var stage_dicts: Dictionary = dictionary.get("stages", {})

	for key: String in stage_dicts:
		profile.stages[StringName(key)] = StageRecord.from_dict(stage_dicts[key])
 
	return profile
