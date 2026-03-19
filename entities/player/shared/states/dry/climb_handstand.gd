
class_name ClimbHandstand
extends PlayerState
## Handstanding at the tip of a [Pole], lining up to jump off.

var carry_pos: Vector2
var carry_height: float

var go_back_down := false

var climb_tween: Tween


func _on_enter(params: Variant) -> void:
	carry_pos = params[0]
	carry_height = params[1]

	go_back_down = false
	climb_tween = null

	actor.velocity = Vector2.ZERO


func _physics_tick(_delta: float) -> void:
	if Input.is_action_pressed(&"down") and not climb_tween:
		climb_tween = create_tween()
		climb_tween.set_ease(Tween.EASE_IN)
		climb_tween.tween_property(
			actor,
			"position",
			actor.position + Vector2(0, 10),
			0.3
		)
		climb_tween.finished.connect(func(): go_back_down = true)


func _trans_rules() -> Variant:
	if go_back_down:
		return [&"Climb", [carry_pos, carry_height]]

	return &""
