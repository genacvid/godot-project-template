@icon("res://resources/gui/parts.svg")
extends Component
class_name PartManagerComponent
const MINIMUM_WEIGHT = 1000
const MAXIMUM_WEIGHT = 6500.0

var current_energy_capacity = 0.0

var total_weight := 0.0
var total_energy_use := 0.0
var speed_modifier := 1.0
@onready var biomech:Biomech = owner
@export var weight_speed_curve:Curve
@onready var parts_array := [head,torso,arms,legs,left_arm_equip,right_arm_equip,left_back_equip,right_back_equip,generator,tcs,booster]
@export_category("Frame")
@export var head:PartHead
@export var torso:PartTorso
@export var arms:PartArms
@export var legs:PartLegs
@export_category("Equip")
@export var left_arm_equip:PartWeapon
@export var right_arm_equip:PartWeapon
@export var left_back_equip:PartWeapon
@export var right_back_equip:PartWeapon
@export_category("Internal")
@export var generator:PartGenerator
@export var tcs:PartTCS
@export var booster:PartBooster
@export_category("Modifications")


func _ready() -> void:
	await owner.ready
	current_energy_capacity = generator.energy_capacity
	for part_data:Part in parts_array:
		if part_data:
			total_weight += part_data.weight
			total_energy_use += part_data.energy_cost
	
	## set booster variables
	biomech.mech_move.BURST_INJECTION_TIME = float(booster.burst_injection) / 100
	biomech.mech_move.BURST_FORCE = float(booster.burst_power) / 10
	biomech.mech_move.BOOST_MAX_SPEED = float(booster.thrust_power) / 100
	biomech.mech_move.BURST_COOLDOWN = float(booster.burst_recovery) / 100
	## calculate speed modifier based on total weight
	## heaviest mechs get 50% of total boost and walk speed
	## lightest mechs get 150% of total boost and walk speed
	## realistically, these values will be between 55%-140%
	## this does not account for potential "underweighting" yet
	total_weight = clamp(total_weight,MINIMUM_WEIGHT,MAXIMUM_WEIGHT)
	var maximum_weight_percentage = (total_weight / MAXIMUM_WEIGHT)
	speed_modifier = 1.0 + weight_speed_curve.sample(maximum_weight_percentage)
	biomech.mech_move.BOOST_MAX_SPEED *= speed_modifier
	biomech.mech_move.WALK_MAX_SPEED *= speed_modifier
	biomech.mech_move.BOOST_SPEED_GAIN *= speed_modifier
	biomech.mech_move.BOOST_MAX_ACCEL *= speed_modifier
	

func _physics_process(delta: float) -> void:
	Debug.say("en",current_energy_capacity)
	if biomech.mech_move.wishjump: ## boosters active, drain en
		var en_mod = 1.0 if entity.is_on_floor() else 2.5
		apply_energy(-float(booster.normal_energy_load * en_mod) / 100.0)
	else:
		apply_energy(float(generator.energy_recharge) / 100.0)
	
func apply_energy(amount:float):
	current_energy_capacity += amount
	current_energy_capacity = clamp(current_energy_capacity,0.0,generator.energy_capacity)
	pass


func _on_biomech_move_component_burst_thrusters_activated() -> void:
	apply_energy(-float(booster.burst_energy_load))
