extends MovementState
class_name MovementStateIdle

func handle_input(_event: InputEvent) -> void: ## Called by the state machine when receiving unhandled input events.
	pass

func update(_delta: float) -> void: ## Called by the state machine on the engine's main loop tick.
	pass

func fixed_update(_delta: float) -> void: ## Called by the state machine on the engine's physics update tick.
	move.update(_delta)
	if move.wishdir: transition.emit(GROUND)
	if move.wishjump: transition.emit(JUMP)
	if not entity.is_on_floor(): transition.emit(AIR)
func enter(previous_state_path: String, data := {}) -> void: ## Called by the state machine upon changing the active state. The `data` parameter is a dictionary with arbitrary data the state can use to initialize itself.
	pass

func exit(_target_state: String = "") -> void:## Called by the state machine before changing the active state. Use this function to clean up the state.
	pass
