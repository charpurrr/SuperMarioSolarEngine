@tool
class_name PStateAnimData
extends Resource
## A class that contains animation data for a [PlayerState].

## Which animation this state will use from the doll's animations.
var animation: String:
	set(val):
		animation = val
		
		var actor: Node = get_local_scene()
		var doll: AnimatedSprite2D
		if is_instance_valid(actor) and actor is Player:
			doll = actor.get_node_or_null(doll_path)

		if is_instance_valid(doll) and doll.sprite_frames.has_animation(val):
			if preview:
				doll.animation = val
## Which frame of the animation is being edited.
var frame: int = 0:
	set(val):
		# This prevents errors during initialisation where the setters run
		# before the properties are loaded in the scene tree.
		if not setup_finished:
			return

		var actor: Node = get_local_scene()
		var doll: AnimatedSprite2D
		var fludd_f: AnimatedSprite2D
		var fludd_b: AnimatedSprite2D
		if is_instance_valid(actor) and actor is Player:
			doll = actor.get_node(doll_path)
			fludd_f = actor.get_node(fludd_f_path)
			fludd_b = actor.get_node(fludd_b_path)
		else:
			return

		if animation.is_empty():
			printerr("No animation selected.")
			return
		if not is_instance_valid(doll):
			printerr("Couldn't find the doll AnimatedSprite2D.")
			return
		if not is_instance_valid(doll.sprite_frames):
			printerr("Couldn't find the doll's sprite frames resource.")
			return
		if not doll.sprite_frames.has_animation(animation):
			printerr("Couldn't find animation '%s' in the doll's sprite frames resource." % animation)
			return
		if not is_instance_valid(fludd_b) or not is_instance_valid(fludd_f):
			printerr("Missing FLUDD sprite! Make sure you have 2 seperate sprites for a front and back layer of FLUDD.")
			return
		if not is_instance_valid(fludd_b.sprite_frames) or not is_instance_valid(fludd_f.sprite_frames):
			printerr("Couldn't find the FLUDD's sprite frames resource while setting frame.")
			return
		if not fludd_b.sprite_frames.has_animation(fludd_animation) or not fludd_f.sprite_frames.has_animation(fludd_animation):
			printerr("Couldn't find animation '%s' in the FLUDD's sprite frames resource." % animation)
			return

		frame = val
		frame = wrapi(val, 0, doll.sprite_frames.get_frame_count(animation))
		notify_property_list_changed()

		if preview:
			doll.animation = animation

			doll.frame = frame
			doll.offset = frame_offset
		if preview_fludd:
			fludd_b.animation = fludd_animation
			fludd_b.offset = fludd_offset
			fludd_f.animation = fludd_animation
			fludd_f.offset = fludd_offset
## Specific offset for this frame.
var frame_offset := Vector2i.ZERO:
	set(val):
		frame_offset = val
		frame_offsets.set(frame, val)

		var actor: Node = get_local_scene()
		var doll: AnimatedSprite2D
		if is_instance_valid(actor) and actor is Player:
			doll = actor.get_node_or_null(doll_path)
		else:
			return

		if preview and is_instance_valid(doll):
			doll.offset = val
	get():
		return frame_offsets.get(frame, Vector2i.ZERO)
## Which FLUDD frame this state frame will use.
var fludd_animation: String:
	set(val):
		# This prevents errors during initialisation where the setters run
		# before the properties are loaded in the scene tree.
		if not setup_finished:
			return

		var actor: Node = get_local_scene()
		var fludd_f: AnimatedSprite2D
		var fludd_b: AnimatedSprite2D
		if is_instance_valid(actor) and actor is Player:
			fludd_f = actor.get_node(fludd_f_path)
			fludd_b = actor.get_node(fludd_b_path)
		else:
			return

		if not is_instance_valid(fludd_b) or not is_instance_valid(fludd_f):
			printerr("Missing FLUDD sprite! Make sure you have 2 seperate sprites for a front and back layer of FLUDD.")
			return
		if not is_instance_valid(fludd_b.sprite_frames) or not is_instance_valid(fludd_f.sprite_frames):
			printerr("Couldn't find the FLUDD's sprite frames resource while setting animation.")
			return
		if not fludd_b.sprite_frames.has_animation(fludd_animation) or not fludd_f.sprite_frames.has_animation(fludd_animation):
			printerr("Couldn't find animation '%s' in the FLUDD's sprite frames resource." % animation)
			return

		fludd_animation = val
		frame_fludd.set(frame, val)

		if preview_fludd:
			fludd_f.animation = val
			fludd_b.animation = val
	get():
		return frame_fludd.get(frame, "default")
var fludd_offset := Vector2i.ZERO:
	set(val):
		fludd_offset = val
		frame_fludd_offsets.set(frame, val)

		var actor: Node = get_local_scene()
		var fludd_f: AnimatedSprite2D
		var fludd_b: AnimatedSprite2D
		if is_instance_valid(actor) and actor is Player:
			fludd_f = actor.get_node_or_null(fludd_f_path)
			fludd_b = actor.get_node_or_null(fludd_b_path)
		else:
			return

		if preview_fludd and is_instance_valid(fludd_b) and is_instance_valid(fludd_f):
			fludd_b.offset = val
			fludd_f.offset = val
	get():
		return frame_fludd_offsets.get(frame, Vector2i.ZERO)
## Toggle previewing your frame and it's offsets.
var preview: bool = false:
	set(val):
		# This prevents errors during initialisation where the setters run
		# before the properties are loaded in the scene tree.
		if not setup_finished:
			return

		var actor: Node = get_local_scene()
		var doll: AnimatedSprite2D
		if is_instance_valid(actor) and actor is Player:
			doll = actor.get_node(doll_path)
		else:
			return

		if animation.is_empty():
			printerr("Cant preview an animation if none is selected.")
			return

		# Extra check we need to add because resources get cached at startup.
		# Only relevant in game hence the editor hint check.
		if not Engine.is_editor_hint() and not is_instance_valid(get_local_scene()):
			return

		if not is_instance_valid(doll):
			printerr("Couldn't find the doll AnimatedSprite2D.")
			return

		if val == false:
			doll.offset = Vector2i.ZERO
			preview_fludd = false
		else:
			doll.offset = frame_offset

		doll.animation = animation
		doll.frame = frame

		if doll.has_meta(&"last_previewed"):
			var last = doll.get_meta(&"last_previewed")
			if is_instance_valid(last):
				last.preview_private = false
				last.preview_fludd = false

		preview_private = val
		doll.set_meta(&"last_previewed", self)

		notify_property_list_changed()
	get():
		return preview_private
## Used to avoid infinite recursion when disabling other preview toggles.
var preview_private: bool = false
## Toggle previewing your frame's FLUDD variant and it's offsets.
var preview_fludd: bool = false:
	set(val):
		preview_fludd = val
		# This prevents errors during initialisation where the setters run
		# before the properties are loaded in the scene tree.
		if not setup_finished:
			return

		var actor: Node = get_local_scene()
		var fludd_f: AnimatedSprite2D
		var fludd_b: AnimatedSprite2D
		if is_instance_valid(actor) and actor is Player:
			fludd_f = actor.get_node(fludd_f_path)
			fludd_b = actor.get_node(fludd_b_path)
		else:
			return

		if not is_instance_valid(fludd_b) or not is_instance_valid(fludd_f):
			printerr("Missing FLUDD sprite! Make sure you have 2 seperate sprites for a front and back layer of FLUDD.")
			return
		if not is_instance_valid(fludd_b.sprite_frames) or not is_instance_valid(fludd_f.sprite_frames):
			printerr("Couldn't find the FLUDD's sprite frames resource.")
			return
		if not fludd_b.sprite_frames.has_animation(fludd_animation) or not fludd_f.sprite_frames.has_animation(fludd_animation):
			printerr("Couldn't find animation '%s' in the FLUDD's sprite frames resource." % animation)
			return

		fludd_b.visible = val
		fludd_f.visible = val

		if val == false:
			fludd_b.offset = Vector2i.ZERO
			fludd_f.offset = Vector2i.ZERO
		else:
			fludd_b.offset = fludd_offset
			fludd_f.offset = fludd_offset

		fludd_b.animation = fludd_animation
		fludd_f.animation = fludd_animation

		notify_property_list_changed()

@export_storage var doll_path: NodePath

## Populated in the setup only for editor purposes. Not used in-game.
var animation_list: PackedStringArray

@export_storage var fludd_f_path: NodePath
@export_storage var fludd_b_path: NodePath
## Populated in the setup only for editor purposes. Not used in-game.
var fludd_animation_list: PackedStringArray

## List of offsets connected to frames.
## Used for referencing these values when you need them in regular code.
@export_storage var frame_offsets: Dictionary[int, Vector2i]
## List of FLUDD animations connected to frames.
## Used for referencing these values when you need them in regular code.
@export_storage var frame_fludd: Dictionary[int, String]
## List of FLUDD offsets connected to frames.
## Used for referencing these values when you need them in regular code.
@export_storage var frame_fludd_offsets: Dictionary[int, Vector2i]

## Flag that defines if the setup function has finished running.
var setup_finished: bool = false


func _init() -> void:
	resource_local_to_scene = true
	call_deferred(&"_setup")


func _setup() -> void:
	# We only need to have these references while editing the data resource
	# in the editor. It's no longer relevant when we're running the game.
	if not Engine.is_editor_hint():
		return

	_update_sprite_paths()

	var actor: Node = get_local_scene()

	var doll = actor.get_node(doll_path)
	var fludd_f = actor.get_node(fludd_f_path)
	var fludd_b = actor.get_node(fludd_b_path)

	animation_list = doll.sprite_frames.get_animation_names()

	if fludd_f.sprite_frames.get_animation_names() != fludd_b.sprite_frames.get_animation_names():
		printerr(
		"FLUDD animations don't match! Check the sprite frame resource in both AnimatedSprite2Ds."
		)
	else:
		fludd_animation_list = fludd_f.sprite_frames.get_animation_names()

	notify_property_list_changed()

	setup_finished = true


func _update_sprite_paths() -> void:
	var actor: Node = get_local_scene()

	if not actor is Player:
		return

	doll_path = actor.get_path_to(actor.doll)
	fludd_f_path = actor.get_path_to(actor.fludd_f)
	fludd_b_path = actor.get_path_to(actor.fludd_b)


func _get_property_list() -> Array[Dictionary]:
	var properties: Array[Dictionary] = [
		{
			"name": "animation",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(animation_list),
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "frame",
			"type": TYPE_INT,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
		{
			"name": "preview",
			"type": TYPE_BOOL,
			"usage": PROPERTY_USAGE_DEFAULT,
		},
	]

	if preview:
		properties.append_array(
			[
				{
					"name": "preview_fludd",
					"type": TYPE_BOOL,
					"usage": PROPERTY_USAGE_DEFAULT,
				},
			]
		)

	properties.append_array(
		[
			{
				"name": "Frame Specifications (Frame %d)" % frame,
				"type": TYPE_NIL,
				"usage": PROPERTY_USAGE_GROUP,
			},
			{
				"name": "frame_offset",
				"type": TYPE_VECTOR2I,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			{
				"name": "fludd_animation",
				"type": TYPE_STRING,
				"hint": PROPERTY_HINT_ENUM,
				"hint_string": ",".join(fludd_animation_list),
				"usage": PROPERTY_USAGE_DEFAULT,
			},
			{
				"name": "fludd_offset",
				"type": TYPE_VECTOR2I,
				"usage": PROPERTY_USAGE_DEFAULT,
			},
		]
	)

	return properties
