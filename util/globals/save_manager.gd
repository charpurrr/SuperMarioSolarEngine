extends Node
## Autoload: SaveManager
## 
## Owns the persistent [Profile] and everything about getting it to and from the disk.
## Only [StageManager] (and menus) should talk to this. Stage objects never do.

signal profile_loaded
signal profile_saved
signal save_failed(reason: String)
 
const SAVE_PATH: String = "user://profile.json"
const TMP_PATH: String = "user://profile.json.tmp"
const BAK_PATH: String = "user://profile.json.bak"
const CORRUPT_PATH: String = "user://profile.json.corrupt"
 
var profile: Profile = Profile.new()
 
## Set when the file on disk was written by a NEWER version of the game.
## We keep playing with defaults but refuse to overwrite the newer save.
var saving_disabled: bool = false
 
 
func _ready() -> void:
	load_profile()

 
func load_profile() -> void:
	saving_disabled = false
 
	var main_exists: bool = FileAccess.file_exists(SAVE_PATH)
	var loaded: Profile = _read_profile(SAVE_PATH)
 
	if loaded == null and main_exists and not saving_disabled:
		# Main file exists but is unreadable: keep it for inspection, try the backup.
		push_warning("SaveManager: main save is corrupt, trying backup.")
		DirAccess.copy_absolute(SAVE_PATH, CORRUPT_PATH)
		loaded = _read_profile(BAK_PATH)
 
	profile = loaded if loaded != null else Profile.new()

	profile_loaded.emit()
 
 
func _read_profile(path: String) -> Profile:
	if not FileAccess.file_exists(path):
		return null
 
	var text: String = FileAccess.get_file_as_string(path)

	if text.is_empty():
		return null
 
	var json: JSON = JSON.new()

	if json.parse(text) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return null
 
	var data: Dictionary = _migrate(json.data)

	if data.is_empty():
		return null
 
	return Profile.from_dict(data)
 
 
## Upgrade old save dictionaries to the current format, one version at a time.
## Returns an empty [Dictionary] if the data can't be used.
func _migrate(data: Dictionary) -> Dictionary:
	var version: int = int(data.get("version", 0))
 
	if version > Profile.VERSION:
		push_error("SaveManager: Profile is from a newer game version (%d > %d). Saving disabled." % [version, Profile.VERSION])
		saving_disabled = true
		return {}
 
	while version < Profile.VERSION:
		#match version:
			# 1:
			#	# EXAMPLE migrating from v1 to v2
				#if not data.has("settings"):
					#data["settings"] = {}
		version += 1
		data["version"] = version
 
	return data

 
## Atomic write: write to a temp file, verify it, back up the old save, then swap.
## A crash at any point leaves either the old or the new save intact, never half of one.
func save_profile() -> bool:
	if saving_disabled:
		return _fail("Saving is disabled (save file is from a newer version).")
 
	var text: String = JSON.stringify(profile.to_dict(), "\t")
 
	var file: FileAccess = FileAccess.open(TMP_PATH, FileAccess.WRITE)

	if file == null:
		return _fail("Could not open temp file: %s" % error_string(FileAccess.get_open_error()))
 
	file.store_string(text)

	var write_error: Error = file.get_error()

	file.close()
 
	if write_error != OK:
		return _fail("Write failed: %s" % error_string(write_error))
 
	# Make sure what we wrote actually parses before it replaces anything.
	if _read_profile(TMP_PATH) == null:
		return _fail("Verification of temp file failed.")
 
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.copy_absolute(SAVE_PATH, BAK_PATH)
 
	var rename_error: Error = DirAccess.rename_absolute(TMP_PATH, SAVE_PATH)

	if rename_error != OK:
		return _fail("Could not replace save file: %s" % error_string(rename_error))
 
	profile_saved.emit()

	return true
 
 
func _fail(reason: String) -> bool:
	push_error("SaveManager: " + reason)
	save_failed.emit(reason)
	return false
 
 
## Drops saved UUIDs that no longer exist in the stage manifest (level was edited).
## Call from [method StageManager.load_stage] before [method StageCache.begin].
func prune_stage(data: StageData) -> void:
	if not profile.stages.has(data.id):
		return

	if profile.stages[data.id].prune(data):
		save_profile()

 
## Wipes progress. Keeps the old file as a backup.
func reset_profile() -> void:
	profile = Profile.new()
	save_profile()
 
