@icon("res://resources/gui/sight.svg")
extends Component
## Provides a field of vision with line of sight checks
class_name SightComponent
@export var area:Area3D
@export var collision:CollisionShape3D
var targets_list:Array[Entity]
func _ready() -> void:
	area.connect("body_entered",func(potential_target):
		if not potential_target in targets_list:
			targets_list.append(potential_target))
	area.connect("body_exited",func(potential_target):
		if potential_target in targets_list:
			targets_list.erase(potential_target))

func check_for_targets() -> Entity:
	var lockbox_priority:Array = []
	var final_target:Entity
	for potential_target:Entity in targets_list:
		## check if we can see our potential target
		if entity.trace.ray_obj(
			area.global_position,
			potential_target.collision.global_position,
			TraceComponent.MASK.GEO | TraceComponent.MASK.ENTITY
			) == potential_target:
			lockbox_priority.append(potential_target)
	for target_idx in lockbox_priority.size():
		if lockbox_priority.size() > 1:
			## TODO: Add different sort logics
			
			## Sort by distance - get closest target
			lockbox_priority.sort_custom(func(a,b):
				return entity.global_position.distance_to(a.global_position) \
				> entity.global_position.distance_to(b.global_position))
			
		final_target = lockbox_priority[target_idx]
	return final_target

func enemy_in_sight() -> bool:
	return entity.damage.team != check_for_targets().damage.team
