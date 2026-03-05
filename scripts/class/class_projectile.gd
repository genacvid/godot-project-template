extends CharacterBody3D
class_name Projectile
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
var attacker:NodePath
var spawn_origin:Vector3
var direction:Vector3
var speed:float = 10.0
var knockback:float = 0.0
var damage:float = 0.0
func _ready() -> void:
	reset_physics_interpolation()
	global_position = spawn_origin
	self.add_collision_exception_with(get_node(attacker))
func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	velocity = direction.normalized() * speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		var object = collision.get_collider(0)
		var pos = collision.get_position(0)
		var normal = collision.get_normal(0)
		if object is Entity:
			deal_damage(object)
		despawn.rpc()
@rpc("any_peer","call_local","reliable")
func despawn():
	multiplayer_synchronizer.public_visibility = false
	queue_free()

func deal_damage(collision:CollisionObject3D):
	var data:Dictionary = {}
	var target_entity:Entity = collision
	var owner_entity = get_node(attacker)
	if target_entity.damage:
		target_entity.damage.hurt.rpc(damage, attacker, data,0)
	if target_entity.move:
		var knockback_vector:Vector3 = global_transform.basis.z
		target_entity.move.knockback.rpc(knockback_vector,knockback)
