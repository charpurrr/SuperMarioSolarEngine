@tool
class_name Checkpoint
extends Node2D

const PARTICLE_SCENE: PackedScene = preload("uid://dw32s0tcs2ltj")

@export var spawn_data: PlayerSpawnData

@export_group("Audiovisual")
@export var particle_speed: float = 1.0
@export var enter_sfx: SoundEffect

@export_range(0.0, 10.0, 1.0, "hide_control", "or_greater")
var particle_amount: int:
	set(val):
		particle_amount = val

		if is_node_ready():
			_init_particles()

@export var path: Path2D

@export_group("Meta")
@export var hologram: Sprite2D
@export var category: StringName
@export var uuid: String

@export_tool_button("Regenerate UUID", "UID")
var uuid_action: Callable = func(): uuid = UUID.get_v4()

var particle_follows: Array[PathFollow2D]
var particle_sprites: Array[AnimatedSprite2D]

var particle_tween: Tween

var active: bool = false:
	set(val):
		active = val

		var anim_name: StringName = &"entered" if val == true else &"normal"

		for i: int in particle_sprites.size():
			particle_sprites[i].play(anim_name)
			particle_sprites[i].frame = i


func _init() -> void:
	add_to_group(TrackedId.GROUP)


func _ready() -> void:
	if is_instance_valid(spawn_data):
		spawn_data.changed.connect(_spawn_data_changed)
		_spawn_data_changed()

	_init_particles()

	if Engine.is_editor_hint():
		TrackedId.ensure_unique(self)
		hologram.visible = true
		return

	hologram.visible = false

	add_to_group(&"checkpoints")

	StageCache.checkpoint_reached.connect(_on_checkpoint_reached)


func _validate_property(property: Dictionary) -> void:
	if property.name == "uuid":
		property.usage |= PROPERTY_USAGE_READ_ONLY


func _spawn_data_changed() -> void:
	hologram.position = spawn_data.offset
	hologram.flip_h = true if spawn_data.starting_direction == 0 else false


func _on_area_2d_body_entered(_body: Node2D) -> void:
	if active: return

	enter_sfx.play(self)

	StageCache.reach_checkpoint(uuid, StageCache.current_area)


## Keeps exactly one checkpoint lit, including ones reached in other areas.
func _on_checkpoint_reached(reached_uuid: String) -> void:
	active = reached_uuid == uuid


func _init_particles() -> void:
	if is_instance_valid(path):
		var children: Array[Node] = path.get_children()

		for child: Node in children:
			child.free()

		particle_follows.clear()
		particle_sprites.clear()
	else:
		push_warning("Missing Path2D. Cannot assign particles.")
		return

	for i: int in particle_amount:
		var particle: PathFollow2D = PARTICLE_SCENE.instantiate()

		path.add_child(particle)
		particle_follows.append(particle)

		var sprite: AnimatedSprite2D = particle.get_child(0)

		particle_sprites.append(sprite)

		sprite.play(&"normal")
		sprite.frame = wrapi(i, 0, sprite.sprite_frames.get_frame_count(sprite.animation))

		var offset: float = 1.0 / particle_amount * i
		particle.set_meta(&"offset", offset)

	var progress: float = 0.0

	while is_inside_tree():
		progress = wrapf(progress + particle_speed, 0.0, 1.001)

		for particle: PathFollow2D in particle_follows:
			var offset_progress: float = progress + particle.get_meta(&"offset")
			particle.progress_ratio = wrapf(offset_progress, 0.0, 1.001)

		await get_tree().process_frame

		if Engine.is_editor_hint():
			break
