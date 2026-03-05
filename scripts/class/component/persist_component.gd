@icon("res://resources/gui/persist.svg")
extends Component
## Persists properties across session, saving them to a file
class_name PersistComponent
@export var persistant_properties:Dictionary
func write_persist():
	Save.current_save_file.persistance[owner.name] = persistant_properties
func restore_persist():
	if Save.current_save_file.persistance.has(owner.name):
		persistant_properties = Save.current_save_file.persistance[owner.name]
