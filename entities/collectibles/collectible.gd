@abstract
@tool
class_name Collectible
extends AnimatedSprite2D
## Abstract class for collectibles. Anything that reacts to being grabbed by the player
## extends from this.
##
## Contains redefinable logic for:[br]
## - The behaviour when being collected.[br]
## - Tracking the state of the collectible across scenes and save files.[br][br]
##
## The root node of every collectible scene carries its own [member category]
## and [member uuid], so each placed instance has a unique identity.[br][br]
##
## [i]Examples include coins, power-ups, shine sprites, ...[/i]

@export var area: Area2D
## The kind of collectible (&"red_coin", &"shine", ...). Needs an entry in [TrackPolicies].
## Set it once on the root of the collectible scene (e.g. in Coin.tscn).
@export var category: StringName
## Generated automatically when the instance is placed in an area scene.
@export var uuid: String

@export_tool_button("Regenerate UUID", "UID")
var uuid_action: Callable = func() -> void: uuid = UUID.get_v4()

var collected: bool = false


func _init() -> void:
	add_to_group(TrackedId.GROUP)


func _ready() -> void:
	if Engine.is_editor_hint():
		TrackedId.ensure_unique(self)
		return

	area.body_entered.connect(_check_body_player)

	if not _is_tracked():
		push_warning("%s has no category or uuid, its state won't be tracked." % name)
		return

	if StageCache.has(category, uuid):
		_on_load_as_collected()
		return

	if StageCache.was_collected_before(category, uuid):
		_on_persistent_load()


func _validate_property(property: Dictionary) -> void:
	if property.name == "uuid":
		property.usage |= PROPERTY_USAGE_READ_ONLY


## Can be redefined by the parent class.
func _on_collect() -> void:
	# Default behaviour: removes the collectible
	# from the stage when collected.
	queue_free()


func _on_load_as_collected() -> void:
	# Default behaviour: removes the collectible
	# from the stage if it was already collected.
	queue_free()


func _on_persistent_load() -> void:
	# Default behaviour: does nothing if the collectible
	# was collected on this save file before.
	pass


func _is_tracked() -> bool:
	return not category.is_empty() and not uuid.is_empty()


## Checks whether or not the body interaction was from a player.
## If that's the case, run [method _on_collect]
## and mark the collectible as collected in its [StageTracker] component.
func _check_body_player(body: Node2D) -> void:
	if collected or body is not Player:
		return

	collected = true

	if _is_tracked():
		StageCache.mark(category, uuid)

	_on_collect()
