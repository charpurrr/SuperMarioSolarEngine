@tool
class_name ResourceGenerator
extends Node
## Base class for toolscripts that can be used to auto-generate resources.

## Press to refresh and re-process all related resources.
@export_tool_button("Generate Missing Resources", "Script")
var refresh_action: Callable = _refresh


## Refresh and re-process all related resources.
func _refresh():
	var resource_list = []

	var filesystem = EditorInterface.get_resource_filesystem()

	_explore_directory(filesystem.get_filesystem(), resource_list)

	_process_all(filesystem, resource_list)

	# Godot tries to find an importer for the type, and there is none.
	# But it's just a regular resource with saved export variables. It should just use the default.
	# Not sure why it throws an error, but it doesn't seem to cause any issues.
	print("Refreshed resources. Godot might throw an import error, but it's not a problem.")


## Explore a directory to find related resources.
func _explore_directory(dir: EditorFileSystemDirectory, resource_list: Array):
	for i in dir.get_subdir_count():
		_explore_directory(dir.get_subdir(i), resource_list)

	for i in dir.get_file_count():
		var file = dir.get_file_path(i)

		if file.ends_with(".tres"):
			var resource = load(file)

			if _is_correct_type(resource):
				resource_list.append(resource)


## Check if a resource is of the correct type to be processed.
## Override with [code]return resource is <ClassName>[/code].
func _is_correct_type(_resource: Resource) -> bool:
	return false


## Called after refreshing the resource list.
## Override to define behavior for processing every resource in sequence.
func _process_all(_filesystem: EditorFileSystem, _resource_list: Array) -> void:
	pass


## Resave changes on a given resource.
func _resave(resource: Resource) -> void:
	const FLAGS = ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS & ResourceSaver.FLAG_CHANGE_PATH
	ResourceSaver.save(resource, resource.resource_path, FLAGS)
