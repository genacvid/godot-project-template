extends EntityState
## A type of state given to Non Player Characters
class_name BehaviorState
const WANDER = &"BehaviorStateWander"
const DEAD = &"BehaviorStateDead"
const WARNING = &"BehaviorStateWarning"
const CHASE = &"BehaviorStateChase"
const ATTACK = &"BehaviorStateAttack"
const PANIC = &"BehaviorStatePanic"
const RETREAT = &"BehaviorStateRetreat"

func model_look_at_target():
	if navigation.agent.distance_to_target() > 1.0:
		entity.camera_root.look_at(navigation.agent.get_next_path_position())
		entity.model_root.rotation.y = entity.camera_root.rotation.y
