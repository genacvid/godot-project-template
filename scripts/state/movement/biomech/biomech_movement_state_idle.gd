extends BiomechMovementState
class_name BiomechMovementStateIdle

func handle_input(_event: InputEvent) -> void: ## Called by the state machine when receiving unhandled input events.
	pass

func update(_delta: float) -> void: ## Called by the state machine on the engine's main loop tick.
	pass
const TURN_SPEED = 10
func fixed_update(_delta: float) -> void: ## Called by the state machine on the engine's physics update tick.
	biomech.model_root.rotation.y = lerp_angle(biomech.model_root.rotation.y,biomech.model_root.rotation.y, _delta * TURN_SPEED)
	mech_move.update(_delta)
	if mech_move.wishdir:
		transition.emit(MECH_GROUND)
	if mech_move.wishjump:
		transition.emit(MECH_JUMP)
	if not biomech.is_on_floor():
		transition.emit(MECH_AIR)
func enter(previous_state_path: String, data := {}) -> void: ## Called by the state machine upon changing the active state. The `data` parameter is a dictionary with arbitrary data the state can use to initialize itself.
	pass

func exit(_target_state: String = "") -> void:## Called by the state machine before changing the active state. Use this function to clean up the state.
	pass
