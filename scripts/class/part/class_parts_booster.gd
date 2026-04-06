extends Part
class_name PartBooster

@export_category("Booster Stats")
@export var thrust_power:int = 1000 ## Horizontal movement force
@export var lift_power:int = 150 ## Vertical movement force
@export var burst_power:int = 100 ## Burst vector movement force
@export var burst_injection:int = 30 ## Amount of time it takes for burst to reach top speed
@export var burst_recovery:int = 16 ## Amount of time it takes for burst to reach top speed
@export var burst_energy_load:int = 240 ## Energy used while burst is engaged.
@export var normal_energy_load:int = 400 ## Energy used while boosters are active.
@export var nerve_load:int = 70 ## Maximum nerve damage built up while active
