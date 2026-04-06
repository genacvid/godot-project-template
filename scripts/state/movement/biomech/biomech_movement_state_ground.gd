extends BiomechMovementState
class_name BiomechMovementStateGround

func handle_input(_event: InputEvent) -> void: ## Called by the state machine when receiving unhandled input events.
	pass

func update(_delta: float) -> void: ## Called by the state machine on the engine's main loop tick.
	if mech_move.wishburst and mech_move.wishdir: mech_move.move_burst()
	pass

func fixed_update(_delta: float) -> void: ## Called by the state machine on the engine's physics update tick.
	mech_move.update(_delta)
	if not mech_move.wishdir:
		transition.emit(MECH_IDLE)
	if mech_move.wishjump:
		mech_move.perform_jump_timer += _delta
		if mech_move.queue_jump:
			mech_move.queue_jump = false
			transition.emit(MECH_JUMP)
	if mech_move.perform_jump_timer == 0.0:
		mech_move.queue_jump = false
	if not mech_move.wishjump:
		if mech_move.perform_jump_timer >= 0.06:
			mech_move.queue_jump = true
		mech_move.perform_jump_timer -= _delta
	mech_move.perform_jump_timer = clamp(mech_move.perform_jump_timer,0.0,0.15)
	if not biomech.is_on_floor():
		transition.emit(MECH_AIR)
func enter(previous_state_path: String, data := {}) -> void: ## Called by the state machine upon changing the active state. The `data` parameter is a dictionary with arbitrary data the state can use to initialize itself.
	pass

func exit(_target_state: String = "") -> void:## Called by the state machine before changing the active state. Use this function to clean up the state.
	mech_move.perform_jump_timer = 0.0
