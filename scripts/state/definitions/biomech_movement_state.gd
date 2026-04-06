extends MovementState
class_name BiomechMovementState
const MECH_GROUND = &"BiomechMovementStateGround"
const MECH_IDLE = &"BiomechMovementStateIdle"
const MECH_JUMP = &"BiomechMovementStateJump"
const MECH_AIR = &"BiomechMovementStateAir"
@onready var biomech:Biomech = owner
@onready var mech_move:BiomechMoveComponent = owner.move
