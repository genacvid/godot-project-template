## Helper class for math functions
class_name Math

## Returns an intercept position for a projectile, useful for "aiming ahead" to hit moving targets
static func get_target_intercept(target_pos:Vector3,origin:Vector3,target_velocity:Vector3,projectile_speed:float) -> Vector3:
	return ( target_pos + (target_velocity * origin.distance_to(target_pos) ) / projectile_speed )

## Useful for decal alignments
static func look_at_with_y(transform:Transform3D,normal:Vector3,v_up:Vector3 = Vector3.UP) -> Transform3D:
	if normal == Vector3.UP or normal == Vector3.DOWN: return transform
	#Y vector
	transform.basis.y=normal.normalized()
	transform.basis.z=v_up*-1
	transform.basis.x = transform.basis.z.cross(transform.basis.y).normalized();
	#Recompute z = y cross X
	transform.basis.z = transform.basis.y.cross(transform.basis.x).normalized();
	transform.basis.x = transform.basis.x * -1
	transform.basis = transform.basis.orthonormalized() # make sure it is valid 
	return transform

## Returns the percentage difference between two numbers. E.g; 
static func percentage_difference(value_a:float,value_b:float) -> float:
	return ((value_a - value_b) / ((value_a + value_b) / 2)) * 100
