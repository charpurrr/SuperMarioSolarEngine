class_name Grounded
extends PlayerState
## A base state for all grounded states.


func _on_enter(play_land_sfx):
	movement.activate_consec_timer()
	movement.consume_freefall_timer()
	movement.air_spun = false
	movement.dived = false

	actor.set_floor_snap_length(movement.snap_length)

	if play_land_sfx:
		# Normal footsteps
		sfx_layers[0].play_sfx_at(self)
		# FLUDD footsteps
		if FluddManager.active_nozzle != FluddManager.Nozzle.NONE:
			sfx_layers[1].play_sfx_at(self)


func _physics_tick(_delta: float):
	if actor.velocity.y < 0:
		actor.velocity.y += 1


func _trans_rules():
	if not actor.is_on_floor():
		return &"Fall"

	return &""


func _defer_rules():
	return &"Idle"
