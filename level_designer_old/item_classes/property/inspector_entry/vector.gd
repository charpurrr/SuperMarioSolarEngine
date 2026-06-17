extends InspectorEntry

@export var component_list: VBoxContainer
@export var component_scene: PackedScene
@export var components: Array[String] = ["x", "y"]


func _ready():
	create_components(components)


## Creates labelled number entries to act as components of the vector.
func create_components(component_labels: Array[String]) -> void:
	var first: bool = true
	for child in component_list.get_children():
		child.queue_free()
	for component_label in component_labels:
		var inst = component_scene.instantiate()
		inst.set_label(component_label)
		inst.value_changed.connect(_update_vector.unbind(1))
		component_list.add_child(inst)
		if first:
			label.custom_minimum_size.y = inst.size.y
			first = false


## Sets the vector value of this entry.
## Decomposes the input vector, setting the child components to equal the components of the input.
func set_value(value: Variant) -> void:
	for i in components.size():
		component_list.get_child(i).set_value(value[i])


## Updates the stored vector value based on the components' values.
func _update_vector() -> void:
	## Manually call [method _on_child_value_changed] to update the stored value.
	_on_child_value_changed(_get_vector())


## Composes a vector from the individual values of the components.
## Returns a [Vector2], [Vector3] or [Vector4], depending on how many components this vector has.
func _get_vector() -> Variant:
	var vec
	var component_count = components.size()
	match component_count:
		2:
			vec = Vector2()
		3:
			vec = Vector3()
		4:
			vec = Vector4()
		_:
			assert(false, "No support for vectors of size %d." % components.size())

	for i in component_count:
		vec[i] = _get_component_value(i)
	return vec


func _get_component_value(idx: int) -> float:
	var component = component_list.get_child(idx)
	return component.get_value()
