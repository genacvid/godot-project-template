extends PartFrame
class_name PartTorso
@export var arm_offset := Vector3.ZERO

@export_group("Torso Functionality")
@export var boost_efficiency:int = 200
@export var energy_efficiency:int = 100
@export var nerve_quality:int = 100 ## Modifies nerve stats
