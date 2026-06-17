@tool
class_name ItemListGenerator
extends ResourceGenerator

@export_file() var item_list_path: String


func _process_all(filesystem, resource_list):
	var item_list := EditorItemList.new()
	item_list.items.append_array(resource_list)
	const FLAGS = ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS & ResourceSaver.FLAG_CHANGE_PATH
	ResourceSaver.save(item_list, item_list_path, FLAGS)

	filesystem.reimport_files([item_list_path])


func _is_correct_type(resource: Resource) -> bool:
	return resource is EditorItemData
