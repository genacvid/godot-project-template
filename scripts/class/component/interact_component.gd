@icon("res://resources/gui/interact.svg")
extends Component
## Handles interact events
class_name InteractComponent

signal interacted
func _interaction():
	interacted.emit()
