class_name LineEditor
extends Line2D
## Base class used for simple user generated line creation and editing.
## Inherited by classes such as [TrackEditor] and [PolygonEditor] for intuitive UIX.

## How close the cursor needs to be toward the center of the line to
## add a point on it.
@export var add_point_margin: int = 5
@export_category("References")
@export var button_widget: PackedScene
@export var curve_button_widget: PackedScene
@export var add_hologram: DraggableButton

## Whether or not the first point has been created.
var drawn_once: bool = false

## The local position of the cursor.
var cursor_pos: Vector2
## Where the cursor was located on its last left click.
var last_click_pos: Vector2
## How close the cursor is to the nearest point on the line.
var min_cursor_dist: float = INF
## Whether or not the cursor is currently hovering over a button widget.
var hovering_over_button: bool = false
## Which segment of the line the cursor is currently closest to.
var closest_segment: PackedVector2Array

### This Line2D converted to different polygons.
#var polyline: Array[PackedVector2Array]

## A list of every segment (point to point) of the line.
var segments: Array[PackedVector2Array]
## A list of every [DraggableButton] widget on the line.
var widget_buttons: Array[DraggableButton]
## A list of every [DraggableButton] widget's position.
var button_positions: PackedVector2Array
## Which [DraggableButton] is currently being dragged around.
## This is [code]null[/code] if no widget is being dragged,
## which means you can use [method is_instance_valid] on this variable
## to easily check if a widget is being dragged around.
var currently_dragging: DraggableButton

var currently_hovered: DraggableButton:
	set(val):
		currently_hovered = val

		if is_instance_valid(val):
			hovering_over_button = true
		else:
			hovering_over_button = false


func _ready() -> void:
	var add_holo_button: TextureButton = add_hologram.get_child(0)

	add_holo_button.button_down.connect(_add_holo_just_pressed)
	add_holo_button.button_up.connect(_add_holo_just_released)


func _process(_delta: float) -> void:
	var label: Label = get_child(0)
	label.text = ""
	for segment in segments:
		label.text += "seg%d: " % segments.find(segment) + str(segment) + "\n"


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"quick_restart"):
		get_tree().reload_current_scene()
		return

	cursor_pos = get_local_mouse_position()

	var focus_owner: Control = get_viewport().gui_get_focus_owner()

	if focus_owner is DraggableButton and focus_owner != add_hologram:
		currently_hovered = focus_owner
	else:
		currently_hovered = null

	_line_editing()


## The process of designing the line and its draggable points.
func _line_editing():
	# Creating the buttons.
	if Input.is_action_just_pressed(&"e_select") and not hovering_over_button and not add_hologram.visible:
		last_click_pos = cursor_pos

		_create_button(
			last_click_pos,
			# New point index is 0 if it's the first point,
			# otherwise it's the last last point and thus the last index.
			-1 if drawn_once else 0,
			!drawn_once
		)

	# When the "add point" hologram is being pressed,
	# it temporarily turns into a make-shift DraggableButton.
	# This is done so the button can stay selected
	add_hologram.draggable = add_hologram.held_down

	# Show the "add point" hologram at the appropriate location
	if not add_hologram.held_down:
		if not is_instance_valid(currently_hovered) and points.size() > 1:
			add_hologram.position = _get_closest_point(cursor_pos)
			add_hologram.visible = min_cursor_dist <= add_point_margin
		else:
			add_hologram.visible = false

	if Input.is_action_just_pressed(&"e_curve_toggle") and hovering_over_button:
		# Toggle Curve -> Default
		if currently_hovered is CurveButton:
			_replace_button(currently_hovered, true, false)
		# Toggle Default -> Curve
		else:
			_replace_button(currently_hovered, true, true)

	# Updating points of the Line2D.
	if (
		Input.is_action_just_pressed(&"e_select") or
		Input.is_action_just_released(&"e_select") or
		get_viewport().gui_get_focus_owner() is DraggableButton or
		add_hologram.held_down
	):
		_sync_p2b()


func _add_holo_just_pressed():
	widget_buttons.insert(segments.find(closest_segment) + 1, add_hologram)


func _add_holo_just_released():
	_replace_button(add_hologram)


## Creates a new widget button at position [param at],
## with index [param idx] (which can be -1 if last available index is desired),
## and uses the flag [param is_first] to handle the button appropriately.
func _create_button(at: Vector2, idx: int, is_first: bool = false, is_curve: bool = false):
	var button_node: DraggableButton

	if is_curve:
		button_node = curve_button_widget.instantiate() as CurveButton
	else:
		button_node = button_widget.instantiate()

	button_node.position = at

	button_node.delete_attempted.connect(_remove_button.bind(button_node))

	button_node.selected.connect(func(button: DraggableButton): currently_dragging = button)
	button_node.deselected.connect(func(_button: DraggableButton): currently_dragging = null)

	# If an index is defined, set the array element to that index.
	if idx != -1:
		widget_buttons.insert(idx, button_node)
	# Otherwise simply add it to the end.
	else:
		widget_buttons.append(button_node)

	if is_first:
		button_node.costume = "Red"
		button_node.set_meta(&"first", true)
		drawn_once = true
	else:
		segments.insert(
			widget_buttons.find(button_node) - 1,
			PackedVector2Array([
				widget_buttons[idx - 1].position,
				widget_buttons[idx].position
			])
		)

	add_child(button_node)


## Replaces [param target] with a new [DraggableButton].
func _replace_button(target: DraggableButton, delete_after: bool = false, is_curve: bool = false):
	var target_idx: int = widget_buttons.find(target)

	widget_buttons.remove_at(target_idx)
	_create_button(target.position, target_idx, false, is_curve)
	_sync_p2b()

	if delete_after:
		target.queue_free()


## [param to_be_removed] is a reference to the point that's being removed.
func _remove_button(to_be_removed: DraggableButton):
	if to_be_removed.has_meta(&"first"):
		# Reset drawn_once if the only existing point was deleted,
		# otherwise make the next point the first point.
		if points.size() == 1:
			drawn_once = false
		else:
			widget_buttons[1].costume = "Red"
			widget_buttons[1].set_meta(&"first", true)

	if points.size() > 1:
		var idx: int = widget_buttons.find(to_be_removed)

		# First point:
		if idx == 0:
			segments.remove_at(0)
		# Last point:
		elif idx == widget_buttons.size() - 1:
			segments.remove_at(idx - 1)
		# Any point in-between:
		elif idx > 0:
			segments.remove_at(idx)
			segments.remove_at(idx - 1)

			var merged_segment := PackedVector2Array([
				widget_buttons[idx - 1].position,
				widget_buttons[idx + 1].position
			])

			segments.insert(idx - 1, merged_segment)

	widget_buttons.erase(to_be_removed)
	to_be_removed.queue_free()

	_sync_p2b()


## Updates the [member points] to correspond with the positions of the [DraggableButton]s.[br]
## If a button was just dragged around, this function updates the segments surrounding it.
## If instead you want to update the segments around a different reference point,
## set [param overwrite_reference] to it.
#func _sync_p2b(overwrite_reference: DraggableButton = null):
	#button_positions = poly_buttons.map(
		#func(button: DraggableButton) -> Vector2: return button.position
	#)
#
	#points = button_positions
#
	#var reference: DraggableButton = null
#
	#if is_instance_valid(overwrite_reference):
		#reference = overwrite_reference
	#else:
		#reference = currently_dragging
#
	## If reference exists, update the segments array as well.
	#if is_instance_valid(reference) and points.size() > 1:
		#var dragging_idx: int = poly_buttons.find(reference)
#
		## Update the left segment [x1,y1;X2,Y2]
		#segments[dragging_idx - 1] = PackedVector2Array([
				#poly_buttons[dragging_idx - 1].position,
				#reference.position
			#])
		## Update the right segment [X1,Y1;x2,y2] (if there is one)
		#if dragging_idx != points.size() - 1:
			#segments[dragging_idx] = PackedVector2Array([
				#reference.position,
				#poly_buttons[dragging_idx + 1].position
			#])


func _sync_p2b():
	# Update button_positions
	button_positions = widget_buttons.map(
		func(button: DraggableButton) -> Vector2: return button.position
	)

	# Update segments
	#var new_segments: Array[PackedVector2Array]
#
	#for i in range(widget_buttons.size() - 1):
		#new_segments.append_array(PackedVector2Array([widget_buttons[i].position, widget_buttons[i + 1].position]))
#
	#segments = new_segments

	# Update points
	var new_points = PackedVector2Array()

	new_points.append(widget_buttons[0].position)

	for i in range(widget_buttons.size() - 1):
		if widget_buttons[i] is CurveButton or widget_buttons[i + 1] is CurveButton:
			new_points.append_array(_get_curve(i, i + 1))
		else:
			new_points.append(widget_buttons[i + 1].position)

	points = new_points


func _get_curve(from: int, to: int) -> PackedVector2Array:
	var curve := Curve2D.new()

	var from_btn: DraggableButton = widget_buttons[from]
	var to_btn: DraggableButton = widget_buttons[to]

	if from_btn is CurveButton:
		curve.add_point(from_btn.position, from_btn.in_offset, from_btn.out_offset)
	else:
		curve.add_point(from_btn.position)

	if to_btn is CurveButton:
		curve.add_point(to_btn.position, to_btn.in_offset, to_btn.out_offset)
	else:
		curve.add_point(to_btn.position)

	var baked: PackedVector2Array = curve.get_baked_points()
	# Avoid duplicate point
	if baked.size() > 1:
		baked.remove_at(0)

	return baked


func _get_closest_point(reference: Vector2) -> Vector2:
	var closest_point: Vector2
	var min_dist: float = INF
	
	for segment in segments:
		var candidate: Vector2 = Geometry2D.get_closest_point_to_segment(reference, segment[0], segment[1])
		var dist: float = reference.distance_to(candidate)

		if dist < min_dist:
			min_dist = dist
			min_cursor_dist = dist
			closest_segment = segment
			closest_point = candidate

	return closest_point


### Check if the polygon you're trying to create doesn't intersect with itself.
#func _check_not_intersecting(poly: PackedVector2Array, new_pos: Vector2) -> bool:
	#var size: int = poly.size()
#
	#if size <= 2:
		#return true
#
	## Last point of the polygon
	#var edge_start: Vector2 = poly[size - 1]
#
	#for i in range(size - 2):
		#if Geometry2D.segment_intersects_segment(poly[i], poly[i + 1], edge_start, new_pos) != null:
			#push_warning("Cannot create a polygon that intersects with itself.")
			#return false
#
	#return true


#func _create_polygon():
	#var body := StaticBody2D.new()
	#get_parent().call_deferred("add_child", body)
#
	#var collision := CollisionPolygon2D.new()
	#var visual := Polygon2D.new()
#
	#collision.polygon = points
	#visual.polygon = points
#
	#collision.position = position
	#visual.position = position
#
	#body.add_child(collision)
	#body.add_child(visual)


#func _close_outline():
	#if not points.size() >= 3:
		#return
#
	#default_color = Color.hex(0xfcc64aff)
	#closed = true
