@icon("res://resources/gui/trace.svg")
extends Component
## Performs direct physics server queries and returns results
class_name TraceComponent
enum MASK{NONE,GEO,ENTITY,HITBOX,PROJECTILE}

## append all collision objects belonging to the entity
func get_exclusion() -> Array:
	var exclusion = [entity]
	if entity.damage:
		if not entity.damage.hitboxes.is_empty():
			exclusion.append_array(entity.damage.hitboxes)
	return exclusion

##
##	Raycasting
##

func raycast(from:Vector3,to:Vector3,mask:int) -> Dictionary:
	var space_state = entity.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from,to,mask)
	query.exclude = get_exclusion()
	var result = space_state.intersect_ray(query)
	return result

func ray_obj(from:Vector3,to:Vector3,mask:int) -> Object:
	var result:Dictionary = raycast(from,to,mask)
	if result.is_empty(): return null
	return result[&"collider"]

func ray_pos(from:Vector3,to:Vector3,mask:int) -> Vector3:
	var result:Dictionary = raycast(from,to,mask)
	if result.is_empty(): return Vector3.ZERO
	return result[&"position"]

func ray_normal(from:Vector3,to:Vector3,mask:int) -> Vector3:
	var result:Dictionary = raycast(from,to,mask)
	if result.is_empty(): return Vector3.ZERO
	return result[&"normal"]
## requires raycast face indexing to be enabled with jolt. will always return -1 if disabled.
func ray_face_idx(from:Vector3,to:Vector3,mask:int) -> int:
	var result:Dictionary = raycast(from,to,mask)
	if result.is_empty(): return -1
	return result[&"face_index"]

##
##	Shapecasting
##

func shapecast(from:Vector3,to:Vector3,mask:int,shape_rid:RID) -> Array[Dictionary]:
	var space_state = entity.get_world_3d().direct_space_state
	var query = PhysicsShapeQueryParameters3D.new()
	query.exclude = get_exclusion()
	query.collision_mask = mask
	query.motion = to - from
	query.shape_rid = shape_rid
	var result = space_state.intersect_shape(query,16)
	return result

func box_cast(from:Vector3,to:Vector3,mask:int,size:Vector3) -> Array[Dictionary]:
	var shape_rid = PhysicsServer3D.box_shape_create()
	PhysicsServer3D.shape_set_data(shape_rid,size)
	var result = shapecast(from,to,mask,shape_rid)
	PhysicsServer3D.free_rid(shape_rid)
	return result

func sphere_cast(from:Vector3,to:Vector3,mask:int,radius:float) -> Array[Dictionary]:
	var shape_rid = PhysicsServer3D.sphere_shape_create()
	PhysicsServer3D.shape_set_data(shape_rid,radius)
	var result = shapecast(from,to,mask,shape_rid)
	PhysicsServer3D.free_rid(shape_rid)
	return result
