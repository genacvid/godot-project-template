@icon("res://resources/gui/persist.svg")
extends Component
## Persists properties across session, saving them to a file
class_name PersistComponent
@export var persistant_properties:Array[String] = []

func write_persist():
	pass
func restore_persist():
	pass
