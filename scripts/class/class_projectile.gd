extends CharacterBody3D
class_name Projectile
var attacker:NodePath
var attack:AttackComponent
var direction:Vector3

func _physics_process(delta: float) -> void:
	velocity = direction.normalized() * attack.current_attack_data.projectile_speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		var object = collision.get_collider(0)
		var pos = collision.get_position(0)
		var normal = collision.get_normal(0)
		if object is PhysicalBone3D:
			attack.deal_damage(object)
		queue_free()
