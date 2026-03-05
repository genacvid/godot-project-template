@icon("res://resources/gui/damage.svg")
extends Component
## Manages health and damage, who attacked, etc
class_name DamageComponent

@export var max_health:float = 100.0
@export var team:int
@onready var health:float = max_health
@export var hitbox_root:PhysicalBoneSimulator3D
@export var behavior_state_machine:StateMachine
var hitboxes:Array[PhysicalBone3D]

signal damaged(attacker:Entity)
signal killed(attacker:Entity)
var dead:bool = false

func _ready() -> void:
	if not hitbox_root: return
	for bone in hitbox_root.get_children():
		assert(bone is PhysicalBone3D,"That's not a hitbox!")
		hitboxes.append(bone)

@rpc("any_peer","call_local")
func hurt(amount:float,_attacker:NodePath,_data:Dictionary,bone_idx:int) -> void:
	if dead: return
	health -= amount
	health = clamp(health, 0.0, max_health)
	damaged.emit(get_node(_attacker))
	if health == 0.0:
		killed.emit(get_node(_attacker))
		if behavior_state_machine:
			behavior_state_machine._transition_to_next_state(BehaviorState.DEAD)
		dead = true
