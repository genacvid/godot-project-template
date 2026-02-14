extends BehaviorState
class_name BehaviorStateWarning

func handle_input(_event: InputEvent) -> void: ## Called by the state machine when receiving unhandled input events.
	pass

func update(_delta: float) -> void: ## Called by the state machine on the engine's main loop tick.
	pass
var warning_timer:float = 1.0
@export var max_warning_timer:float = 2.0
func fixed_update(_delta: float) -> void: ## Called by the state machine on the engine's physics update tick.
	if sight.check_for_targets() == navigation.target_entity: warning_timer += _delta
	else: warning_timer -= _delta
	if warning_timer >= max_warning_timer: transition.emit(CHASE)
	if warning_timer == 0.0: transition.emit(WANDER)
	
func enter(previous_state_path: String, data := {}) -> void: ## Called by the state machine upon changing the active state. The `data` parameter is a dictionary with arbitrary data the state can use to initialize itself.
	pass

func exit(_target_state: String = "") -> void:## Called by the state machine before changing the active state. Use this function to clean up the state.
	warning_timer = 1.0
