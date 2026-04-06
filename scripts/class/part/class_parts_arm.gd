extends PartFrame
class_name PartArms

@export_group("Arm Functionality")
@export var recoil_control:int = 0 ## Dampens maximum weapon spread
@export var weapon_accuracy:int = 100 ## Increases tracking speed
@export var arms_weight_limit:int = 0 ## Maximum weapon equip load for weapons and expansion parts
@export var melee_power:int = 100 ## Modifier for melee damage (default 100%)
@export var attack_data:AttackData ## Used for arms weapons
