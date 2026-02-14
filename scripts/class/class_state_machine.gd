@icon("res://resources/gui/statemachine.svg")
extends Node
## Switches between logical blocks known as States
class_name StateMachine

@export var initial_state:State
@onready var state:State = initial_state

func _ready() -> void:
	if not is_multiplayer_authority(): return
	assert(initial_state != null,"No initial state was set")
	for state_node:State in self.get_children():
		state_node.transition.connect(_transition_to_next_state)
	await owner.ready
	state.enter("")

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	state.handle_input(event)

func _process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	state.update(delta)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	state.fixed_update(delta)

func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not is_multiplayer_authority(): return
	assert(has_node(target_state_path),"State not found in " + self.name)
	var previous_state_path := state.name
	state.exit(target_state_path)
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)
