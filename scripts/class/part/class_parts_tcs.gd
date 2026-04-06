extends Part
class_name PartTCS
@export_group("Target Functionality")
@export var max_distance:float=400
@export_enum("Standard","None","Melee","Close Range","Long Range","Vertical") var lock_type:int ##Provides a bonus to a matching TCS type
@export var width:float = 20
@export var height:float = 20
@export var acquisition_speed:float = 120
@export var missile_processing:float = 50
