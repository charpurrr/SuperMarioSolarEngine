@tool
class_name StageData
extends Resource
## Static description of one stage.
## 
## Its area scenes plus every tracked object's
## category and UUID. Fill in the exports by hand, then press "Bake Stage Data".

const SPAWN_GROUP: StringName = &"player_spawn_points"

@export var id: StringName

@export var areas: Dictionary[StringName, PackedScene]
@export var start_area: StringName
## Name of the spawn point node in [member start_area].
@export var start_spawn: StringName

@export_tool_button("Bake Stage Data", "Reload")
var bake_action: Callable = bake

## Filled by the bake. category -> Array[String] of UUIDs. Don't edit by hand.
@export var tracked: Dictionary[StringName, Array] = {}


func _validate_property(property: Dictionary) -> void:
	if property.name == "tracked":
		property.usage |= PROPERTY_USAGE_READ_ONLY


func total(category: StringName) -> int:
	return tracked.get(category, []).size()


## Walks every area scene and rebuilds [member tracked]. Aborts and keeps the
## old data if anything is wrong (missing UUID, duplicate UUID, bad start).
func bake() -> void:
	var result: Dictionary[StringName, Array] = {}
	# uuid -> where it was found
	var seen: Dictionary = {}
	# area_id -> Array of spawn point names
	var spawns: Dictionary = {}
	var errors: PackedStringArray = []

	if id.is_empty():
		errors.append("Stage has no id.")

	if areas.is_empty():
		errors.append("Stage has no areas.")

	for area_id: StringName in areas:
		var scene: PackedScene = areas[area_id]

		if scene == null:
			errors.append("Area '%s' has no scene." % area_id)
			continue

		var root: Node = scene.instantiate()
		var spawn_names: Array = []

		_scan(root, root, area_id, result, seen, spawn_names, errors)

		spawns[area_id] = spawn_names
		root.free()

	if not areas.has(start_area):
		errors.append("start_area '%s' is not one of the areas." % start_area)
	elif start_spawn not in spawns.get(start_area, []):
		errors.append("start_spawn '%s' not found in area '%s' (spawn points are matched by node name)." % [start_spawn, start_area])

	if not errors.is_empty():
		for error: String in errors:
			push_error("StageData bake: " + error)
		push_error("StageData bake aborted, previous data kept.")
		return

	for category: StringName in result:
		result[category].sort()

	tracked = result
	emit_changed()

	ResourceSaver.save(self)

	var summary: PackedStringArray = []
	for category: StringName in result:
		summary.append("%s: %d" % [category, result[category].size()])

	print("StageData '%s' baked. %s" % [id, ", ".join(summary)])


func _scan(
		node: Node,
		root: Node,
		area_id: StringName,
		result: Dictionary[StringName, Array],
		seen: Dictionary,
		spawn_names: Array,
		errors: PackedStringArray
	) -> void:
	if node.is_in_group(SPAWN_GROUP):
		spawn_names.append(node.name)

	if node.is_in_group(TrackedId.GROUP):
		var where: String = "%s:%s" % [area_id, root.get_path_to(node)]
		var category: StringName = node.get(&"category")
		var uuid: String = node.get(&"uuid")

		if category == null or category.is_empty():
			errors.append("%s has no category." % where)
		elif uuid == null or uuid.is_empty():
			errors.append("%s has no UUID. Open the area scene in the editor once so one is generated, then save it." % where)
		elif seen.has(uuid):
			errors.append("Duplicate UUID %s: %s and %s." % [uuid, seen[uuid], where])
		else:
			seen[uuid] = where
			result.get_or_add(category, []).append(uuid)

	for child: Node in node.get_children():
		_scan(child, root, area_id, result, seen, spawn_names, errors)
