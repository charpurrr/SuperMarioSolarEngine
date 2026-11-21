@tool
class_name TrackedId
extends RefCounted
## Editor-only helper that keeps the "UUID" property of tracked nodes unique.
## Call [method ensure_unique] from the node's _ready().

const GROUP: StringName = &"stage_tracked"


static func ensure_unique(node: Node) -> void:
	if not Engine.is_editor_hint() or not node.is_inside_tree():
		return

	var root: Node = node.get_tree().edited_scene_root

	# Skip the scene being edited as a template (e.g. opening Coin.tscn itself)
	# and anything nested inside another instanced scene.
	if root == null or node == root or node.owner != root:
		return

	var uuid: String = node.get(&"uuid")

	if uuid.is_empty() or _is_taken(node, root, uuid):
		node.set(&"uuid", UUID.get_v4())


static func _is_taken(node: Node, root: Node, uuid: String) -> bool:
	for other: Node in node.get_tree().get_nodes_in_group(GROUP):
		if other == node or other.owner != root:
			continue

		if str(other.get(&"uuid")) == uuid:
			return true

	return false
