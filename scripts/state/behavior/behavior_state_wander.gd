extends BehaviorState
class_name BehaviorStateWander

func handle_input(_event: InputEvent) -> void: ## Called by the state machine when receiving unhandled input events.
	pass

func update(_delta: float) -> void: ## Called by the state machine on the engine's main loop tick.
	pass
var wander_timer:float = 0.0
@export var max_wander_timer:float = 3.0
@export var is_aggressive:bool = false
func fixed_update(_delta: float) -> void: ## Called by the state machine on the engine's physics update tick.
	if input: return
	wander_timer += _delta
	if wander_timer >= max_wander_timer:
		navigation.set_random_location()
		wander_timer = 0.0
	navigation.update()
	
func enter(previous_state_path: String, data := {}) -> void: ## Called by the state machine upon changing the active state. The `data` parameter is a dictionary with arbitrary data the state can use to initialize itself.
	navigation.set_random_location()

func exit(_target_state: String = "") -> void:## Called by the state machine before changing the active state. Use this function to clean up the state.
	wander_timer = 0.0
