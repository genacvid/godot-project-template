extends Entity
class_name Explosion
@export var attack_data:AttackData
var attacker:NodePath
@export var hitbox:Area3D
@export var falloff_curve:Curve
@export var radius:float = 2.0
func attack_explosion():
	await get_tree().physics_frame
	for body:CollisionObject3D in hitbox.get_overlapping_bodies():
		if body is Entity:
			print(body)
			var from = hitbox.global_position
			var to = body.collision.global_position
			var obj = trace.ray_obj(from,to,2|1)
			var normal = trace.ray_normal(from,to,2|1)
			var distance_ratio = from.distance_squared_to(to) / radius
			var modifier:float = falloff_curve.sample(distance_ratio)
			if trace.ray_obj(hitbox.global_position,body.collision.global_position,2|1) == body:
				if body.damage:
					body.damage.hurt.rpc(attack_data.damage*modifier,attacker,{},0)
				if body.move:
					body.move.knockback.rpc(normal,attack_data.knockback*modifier)
	queue_free()
