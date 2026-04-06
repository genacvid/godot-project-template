extends PartFrame
class_name PartLegs

@export_enum("Bipedal","Reverse Joint","Quadruped","Vehicular","Levitation") var leg_type:int = 0

@export_group("Legs Functionality")
@export var legs_equip_load:int = 0
@export var jumping_power:int = 75
@export var turning_ability:int = 85
@export var ground_speed_adjust:int = 100
