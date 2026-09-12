class_name DebugOverlay
extends Control
## Diagnostic overlay used for debugging.
##
## Some of the features of the [DebugOverlay] only work
## in the debug build of the engine.

## Diagnostic information on the left side of the screen.
@export var label_l: RichTextLabel
## Diagnostic information on the right side of the screen.
@export var label_r: RichTextLabel
## Container for displayed keyboard inputs.
@export var input_keyboard_display: TextureRect
## Container for displayed mouse inputs.
@export var input_mouse_display: TextureRect

## Dictionary of displayed inputs with identifiers as keys,
## and their overlay [TextureRect]s as values.
var displayed_inputs: Dictionary[String, TextureRect]

## List of active [PlayerState]s.
var active_states: Array[PlayerState]

## Reference to the player set by the [UserInterface].
@onready var player: Player


func _ready() -> void:
	_check_active_debug()
	_check_active_debug_hitboxes()

	# This refreshes the input display when the window gets focused/unfocused
	# to avoid indefinitely pressed keys.
	get_window().focus_exited.connect(_clear_input_display)
	get_window().focus_entered.connect(_clear_input_display)

	LocalSettings.setting_changed.connect(_setting_changed)


func _physics_process(_delta: float) -> void:
	_update_labels()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return

	var appropriate_display: TextureRect
	var event_id: String

	if event is InputEventKey:
		appropriate_display = input_keyboard_display
		event_id = str(event.physical_keycode)
	elif event is InputEventMouseButton:
		appropriate_display = input_mouse_display
		event_id = "M:" + str(event.button_index)

	_display_input(event, appropriate_display, event_id)


## Displays the given [param event] by displaying its appropriate texture
## on a [TextureRect] within the appropriate [member display] container.
## The [param event_id] is the string used to reference displayed inputs,
## this can be anything as long as its unique per input.
func _display_input(event: InputEvent, display: TextureRect, event_id: String):
	if event.is_released() and displayed_inputs.has(event_id):
		display.remove_child(displayed_inputs[event_id])
		displayed_inputs.erase(event_id)
	elif not displayed_inputs.has(event_id):
		var texture: DPITexture = _get_texture_from_event(event)

		if texture == null:
			return

		var tex_rect: TextureRect = TextureRect.new()

		# Anchor Full Rect
		tex_rect.anchor_left = 0.0
		tex_rect.anchor_top = 0.0
		tex_rect.anchor_right = 1.0
		tex_rect.anchor_bottom = 1.0

		tex_rect.texture = texture

		displayed_inputs[event_id] = tex_rect
		display.add_child(tex_rect)


## Clears the input display by deleting all the created [TextureRect]s for every display,
## and clearing the [member displayed_inputs] array.
func _clear_input_display():
	displayed_inputs.clear()

	for child: TextureRect in input_keyboard_display.get_children():
		child.queue_free()
	for child: TextureRect in input_mouse_display.get_children():
		child.queue_free()


## Returns a UID to the .svg overlays based on [param event].
func _get_texture_from_event(event: InputEvent) -> DPITexture:
	if event is InputEventKey:
		match event.physical_keycode:
			KEY_0: return load("uid://6128ihjgu33p")
			KEY_1: return load("uid://dm2r3hf67riyh")
			KEY_2: return load("uid://bxyjrpfa6rdrn")
			KEY_3: return load("uid://wuaswrolfw5c")
			KEY_4: return load("uid://484cs2e8hjle")
			KEY_5: return load("uid://whc6omoahlsu")
			KEY_6: return load("uid://dgfv00nodmuje")
			KEY_7: return load("uid://fg3q3mjg47l3")
			KEY_8: return load("uid://bq7e6an1dmgyt")
			KEY_9: return load("uid://pxxcsnc1eb4e")

			KEY_A: return load("uid://duyqueyh6iwuc")
			KEY_B: return load("uid://btgtmtw381j6w")
			KEY_C: return load("uid://dtm40husu263t")
			KEY_D: return load("uid://bha323pbwhn08")
			KEY_E: return load("uid://divjvnapwlbr5")
			KEY_F: return load("uid://ccsb5rptv8gr5")
			KEY_G: return load("uid://foqsrei6vqav")
			KEY_H: return load("uid://bwb1s05gfalw7")
			KEY_I: return load("uid://3scc204ffrth")
			KEY_J: return load("uid://cj2e6nenb5lpv")
			KEY_K: return load("uid://dsxdsmk8srt2e")
			KEY_L: return load("uid://beq151bouiobn")
			KEY_M: return load("uid://dpc1i1ndrvccq")
			KEY_N: return load("uid://ddi13p6ygy2d")
			KEY_O: return load("uid://dil34531rklam")
			KEY_P: return load("uid://dk0056wpforg")
			KEY_Q: return load("uid://dex2sgquegmgr")
			KEY_R: return load("uid://dhv783shviy28")
			KEY_S: return load("uid://cm2kk5gkml6yv")
			KEY_T: return load("uid://dsmx4ajmitv4e")
			KEY_U: return load("uid://b1w6w6aqn0aev")
			KEY_V: return load("uid://y2ejwtl4yp8m")
			KEY_W: return load("uid://be2duuhekpsge")
			KEY_X: return load("uid://dswcb8k3fjtuu")
			KEY_Y: return load("uid://c6auk8tutr4ov")
			KEY_Z: return load("uid://cmafu6hknmlaw")

			KEY_APOSTROPHE: return load("uid://c4rsgcowebur")
			KEY_BACKSLASH: return load("uid://dsmcacqe41000")
			KEY_BACKSPACE: return load("uid://d0u6qb370012s")
			KEY_BRACKETLEFT: return load("uid://cnomg7xvlq2yf")
			KEY_BRACKETRIGHT: return load("uid://y6avcq0n4tpk")
			KEY_CAPSLOCK: return load("uid://b3yen7i76e5tc")
			KEY_COMMA: return load("uid://2uqwrp7eojap")
			KEY_ENTER: return load("uid://c08yfu2aicn2d")
			KEY_EQUAL: return load("uid://cqamxt5wlwci5")
			KEY_MENU: return load("uid://s7cdc0dqhirr")
			KEY_MINUS: return load("uid://cahe8tyoac3gs")
			KEY_PERIOD: return load("uid://gnuixsnrl1oi")
			KEY_QUOTELEFT: return load("uid://b7xwmjiqi5rfn")
			KEY_SEMICOLON: return load("uid://d1awo38ldrgqy")
			KEY_SLASH: return load("uid://csurn1lpx5itu")
			KEY_SPACE: return load("uid://dbp3qv5iaic0i")
			KEY_TAB: return load("uid://d02a5swvbqdah")

			KEY_DOWN: return load("uid://dkyy30clh28g5")
			KEY_LEFT: return load("uid://drl310xujbs5s")
			KEY_RIGHT: return load("uid://dpy1p8i4y8rlt")
			KEY_UP: return load("uid://cwc2cw5u20pvh")

			KEY_ALT:
				if event.location == KEY_LOCATION_LEFT:
					return load("uid://tf20wpeo0vbd")
				else:
					return load("uid://dne7qde6pjh11")
			KEY_CTRL:
				if event.location == KEY_LOCATION_LEFT:
					return load("uid://dhgihs1di8vlf")
				else:
					return load("uid://cn3uh76uvvxx0")
			KEY_SHIFT:
				if event.location == KEY_LOCATION_LEFT:
					return load("uid://b2n562psqkm4t")
				else:
					return load("uid://1q6ccdy2wgeg")
			KEY_META:
				if event.location == KEY_LOCATION_LEFT:
					return load("uid://f3mkdmyxxovc")
				else:
					return load("uid://bcqk61y0b2k1t")

			_: return null
	elif event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT: return load("uid://cpc0m1bs2g3ue")
			MOUSE_BUTTON_RIGHT: return load("uid://h6ddkrblge2k")
			MOUSE_BUTTON_MIDDLE: return load("uid://bcc2ie4r4ei12")
			_: return null

	return null


## Toggles the [DebugOverlay] based on the [member debug_toggle] state in [GameState].
## Stops processing when inactive.
func _check_active_debug() -> void:
	var is_active: bool = GameState.debug_toggle

	visible = is_active

	if is_active:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED


## Toggles the built-in debug collisions hint based on the
## [member debug_toggle_hitboxes] state in [GameState].
func _check_active_debug_hitboxes() -> void:
	var is_active: bool = GameState.debug_toggle_hitboxes

	get_tree().set_debug_collisions_hint(is_active)
	# This fixes some buggy behavior which causes the changes
	# to not be visible unless the window is resized.
	get_tree().root.emit_signal(&"visibility_changed")


## Updates both the left and right diagnostic information labels.
func _update_labels() -> void:
	_update_left_label()
	_update_right_label()


## Updates all the diagnostic modules on the left side of the screen.
func _update_left_label():
	var modules_l: PackedStringArray

	modules_l.append("[bgcolor=#5a5a5ab0]")

	modules_l.append("")
	modules_l.append(
		str(snappedf(Engine.get_frames_per_second(), 0.001)) + " FPS"
	)
	modules_l.append(
		str(roundi(Performance.get_monitor(Performance.TIME_PROCESS) * 1000000))
		+ "us process time"
	)
	modules_l.append(
		str(roundi(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000000))
		+ "us physics time"
	)

	modules_l.append("")
	modules_l.append("PXY: " +
		"\t" + str(snappedf(player.global_position.x, 0.01)) +
		"\t" + " / " +
		"\t" + str(snappedf(player.global_position.y, 0.01))
	)
	modules_l.append("VXY: " +
		"\t" + str(snappedf(player.velocity.x, 0.01)) +
		"\t" + " / " +
		"\t" + str(snappedf(player.velocity.y, 0.01))
	)
	modules_l.append("ROT: " +
		str(snappedf(player.movement.body_rotation, 0.001))
	)

	modules_l.append("")

	var is_on_floor: String = \
	"[color=lime]TRUE[/color]" if player.is_on_floor() else \
	"[color=red]FALSE[/color]"
	modules_l.append("Grounded: " + is_on_floor)

	var can_air_action: String = \
	"[color=lime]TRUE[/color]" if player.movement.can_air_action() else \
	"[color=red]FALSE[/color]"
	modules_l.append("Can air action: " + can_air_action)
	modules_l.append(
		"Ground angle: " +
		str(snappedf(player.get_floor_angle() / TAU, 0.001))
	)
	modules_l.append(
		"Ground incline: " +
		str(snappedf(player.movement.get_floor_incline(), 0.001))
	)
	modules_l.append("Facing: " + str(player.movement.facing_direction))

	modules_l.append("")
	modules_l.append("Doll frame: " + str(player.doll.frame))
	modules_l.append("Doll offset: " + str(player.doll.offset))
	modules_l.append("Doll ROT: " + str(snappedf(player.doll.rotation, 0.001)))

	modules_l.append("")
	
	var hitboxes_state: String = \
	"[color=lime]ENABLED[/color]" if GameState.debug_toggle_hitboxes else \
	"[color=red]DISABLED[/color]"
	modules_l.append("Hitboxes: " + hitboxes_state)

	modules_l.append("")
	modules_l.append("")
	modules_l.append(
		"Toggle overlay: " +
		InputMap.action_get_events("debug_toggle")[0].as_text()
	)
	modules_l.append(
		"Toggle hitboxes: " +
		InputMap.action_get_events("debug_toggle_hitboxes")[0].as_text()
	)

	label_l.text = "\n".join(modules_l)


## Updates all the diagnostic modules on the right side of the screen.
func _update_right_label():
	var modules_r: PackedStringArray

	modules_r.append("[bgcolor=#5a5a5ab0]")

	modules_r.append("")
	modules_r.append(Time.get_datetime_string_from_system(false, true))

	modules_r.append("")
	modules_r.append("OS: " + OS.get_distribution_name())

	modules_r.append("")
	var mem_static: float = Performance.get_monitor(Performance.MEMORY_STATIC)
	var mem_static_max: float = Performance.get_monitor(Performance.MEMORY_STATIC_MAX)
	# Conversion from BYTE to MEBIBYTE is / 1048576
	modules_r.append(
		"MEM: "
		+ str(roundi(mem_static / mem_static_max * 100))
		+ "% "
		+ str(snappedf(mem_static / 1048576, 0.01))
		+ "/"
		+ str(snappedf(mem_static_max / 1048576, 0.01))
		+ " MiB"
	)

	modules_r.append("")
	modules_r.append("Total Nodes: "
		+ str(roundi(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)))
	)
	modules_r.append(
		"Rendered OBJ: "
		+ str(roundi(Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)))
	)

	modules_r.append("")
	modules_r.append("GPU: " + RenderingServer.get_video_adapter_name())
	modules_r.append("Display: "
		+ str(WindowSizer.window_size.x)
		+ "x"
		+ str(WindowSizer.window_size.y)
	)
	var video_mem: float = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	modules_r.append(
		"VMEM: "
		+ str(snappedf(video_mem / 1048576, 0.01))
		+ "MiB"
	)

	modules_r.append("")
	modules_r.append("CPU: " + OS.get_processor_name())

	modules_r.append("")
	var is_dbg_build: String = \
	"[color=lime]TRUE[/color]" if OS.is_debug_build() else \
	"[color=red]FALSE[/color]"
	modules_r.append("Dbg build: " + is_dbg_build) 

	modules_r.append("")
	modules_r.append(_get_pretty_state_tree())

	label_r.text = "\n".join(modules_r)


## Returns a multiline string representing the active [PlayerStateManager] branch.
func _get_pretty_state_tree() -> String:
	var text: String = ""

	active_states.clear()
	_fetch_active_superstates(player.state_manager.live_substate)

	text += "StateManager╶┚"

	for state: PlayerState in active_states:
		text += "\n" + state.name + "╶┨"

	return text


## Recursive operation that appends all active [PlayerState]s to the
## [member active_states] array.
func _fetch_active_superstates(state: PlayerState):
	if state == null:
		return

	active_states.append(state)
	_fetch_active_superstates(state.live_substate)


func _setting_changed(key: String, _value: Variant) -> void:
	if key == "debug_toggle":
		_check_active_debug()
	if key == "debug_toggle_hitboxes":
		_check_active_debug_hitboxes()
