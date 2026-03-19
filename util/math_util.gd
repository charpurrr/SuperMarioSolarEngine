class_name Math
## Provides useful math functions that you can call using [code]Math.function_name()[/code].


## If input is positive, returns 1. If input is negative or zero, returns 0.
static func sign_positive(input: Variant) -> Variant:
	return max(sign(input), 0)


## Makes a weight supplied to a [method @GlobalScope.lerp] or
## [method @GlobalScope.cubic_interpolate] function framerate independent
## (for procedural animations with either method).
static func interp_weight_idp(weight : float, delta : float) -> float:
	return 1 - exp(-weight * delta)


static func random_coord(offset: float) -> Vector2:
	return Vector2(randf_range(-offset, offset), randf_range(-offset, offset))


## Maps a value between [param value_min] and [param value_max] to a
## proportional value between [param new_min] and [param new_max].
static func map(value: float, value_min: float, value_max: float, new_min: float, new_max: float) -> float:
	var clamped_value = clamp(value, value_min, value_max)
	return (clamped_value - value_min) * (new_max - new_min) / (value_max - value_min) + new_min


#region LERPS
## Acts like a lerp but skips to the end value if [code]end - start < diff[/code].
static func lerp_fr(start: float, end: float, incr: float, diff: float):
	if abs(end - start) < diff:
		if incr >= 0: return end
		if incr < 0: return start
	return start + (end - start)*incr


## Lerp function for any type of vector, includes the functionality of [method lerpfr].
static func lerp_vecr(vec_start: Variant, vec_end: Variant, incr: float, diff: float):
	if not _vector_type_check(vec_start, vec_end): return

	if vec_start.distance_to(vec_end) < diff:
		if incr >= 0: return vec_end
		if incr < 0: return vec_start
	return vec_start + (vec_end - vec_start) * incr


## Lerp function for colors, includes the functionality of [method lerp_fr].
static func lerp_colr(col_start: Color, col_end: Color, incr: float, diff: float):
	if _dist_color(col_start, col_end) < diff:
		if incr >= 0: return col_end
		if incr < 0: return col_start
	return col_start + (col_end-col_start)*incr
#endregion


## Linear interpolation between floats from start to end by increment.
static func moveto_f(start: float, end: float, incr: float):
	var direction = sign(end - start)
	var dist = abs(end - start)
	return start + direction*incr if dist > incr else end


## Linear interpolation between any type of vector from start to end by increment.
static func moveto_vec(vec_start: Variant, vec_end: Variant, incr: float):
	if not _vector_type_check(vec_start, vec_end): return

	var direction = (vec_end - vec_start).normalized()
	var dist = vec_start.distance_to(vec_end)
	return vec_start + direction*incr if dist > incr else vec_end


static func ease_out(progress: float) -> float:
	return 1.0 - pow(1.0 - progress, 3.0)


static func ease_in_out(progress: float):
	return pow(progress, 2.0) * (3.0 - 2.0 * progress)


static func _vector_type_check(vec_start: Variant, vec_end: Variant) -> bool:
	if vec_start is not Vector2 and vec_start is not Vector3 and vec_start is not Vector4:
		push_error("vec_start is not a Vector type. Did you mean moveto_f?")
		return false
	if vec_end is not Vector2 and vec_end is not Vector3 and vec_end is not Vector4:
		push_error("vec_start is not a Vector type. Did you mean moveto_f?")
		return false
	if typeof(vec_start) != typeof(vec_end):
		push_error("Mismatching types, make sure vec_start and vec_end are the same type of vector.")
		return false

	return true


static func _dist_color(col_start: Color, col_end: Color):
	var r = col_start.r - col_end.r
	var g = col_start.g - col_end.g
	var b = col_start.b - col_end.b
	var a = col_start.a - col_end.a

	return sqrt(r*r + g*g + b*b + a*a)


### Returns the closest point on a line in relation to the reference point.
#static func get_closest_point_line(
		#start_line: Vector2,
		#end_line: Vector2,
		#ref_point: Vector2
	#) -> Vector2:
#
	#var s_to_r := Vector2(ref_point.x - start_line.x, ref_point.y - start_line.y)
	#var s_to_e := Vector2(end_line.x - start_line.x, end_line.y - start_line.y)
#
	## Squared magnitude of the line.
	#var sqr_magnitude: float = pow(s_to_e.x, 2) + pow(s_to_e.y, 2)
#
	## The normalized "distance" from the start of the line to the reference point.
	#var t = s_to_r.dot(s_to_e) / sqr_magnitude
#
	## Add the distance to the starting point, moving towards the ending point.
	#return Vector2(start_line.x + s_to_e.x * t, start_line.y + s_to_e.y * t)
