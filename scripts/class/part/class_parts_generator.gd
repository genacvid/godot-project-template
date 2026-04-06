extends Part
class_name PartGenerator

@export var energy_capacity:int = 2000 ## Total amount of energy that can be used before burning out
@export var energy_recharge:int = 1000 ## How quickly energy recharges, influenced by total energy load
@export var max_energy_load:int = 5000 ## How much energy load this generator can handle, cannot deploy when over this limit.
@export var emergency_power:int = 200 ## How quickly the generator recharges after burning out
@export var nerve_capacity:int = 500 ## How much nerve degredation this generator can handle
@export var nerve_restoration:int = 500 ## How much nerve capacity is restored over time
