@icon("res://resources/gui/state.svg")

extends Node
## A logical block that separates common script functionality into nodes
class_name State
@onready var state_machine:StateMachine = get_parent()

signal transition(next_state_path: String, data: Dictionary)

func handle_input(_event:InputEvent) -> void:
	pass

func update(_delta:float) -> void:
	pass

func fixed_update(_delta:float) -> void:
	pass
	
func enter(_previous_state:String,_data:Dictionary={}) -> void:
	pass

func exit(_target_state:String="") -> void:
	pass
