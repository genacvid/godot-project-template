extends BiomechMovementState
class_name BiomechMovementStateAir

func handle_input(_event: InputEvent) -> void: ## Called by the state machine when receiving unhandled input events.
	pass

func update(_delta: float) -> void: ## Called by the state machine on the engine's main loop tick.
	if mech_move.wishburst and mech_move.wishdir: mech_move.move_burst()
	pass

func fixed_update(_delta: float) -> void: ## Called by the state machine on the engine's physics update tick.
	mech_move.update(_delta)
	if biomech.is_on_floor():
		transition.emit(MECH_GROUND)
func enter(previous_state_path: String, data := {}) -> void: ## Called by the state machine upon changing the active state. The `data` parameter is a dictionary with arbitrary data the state can use to initialize itself.
	pass

func exit(_target_state: String = "") -> void:## Called by the state machine before changing the active state. Use this function to clean up the state.
	mech_move.vertical_velocity = 0.0
