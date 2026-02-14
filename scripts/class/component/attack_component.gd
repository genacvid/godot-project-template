@icon("res://resources/gui/attack.svg")
extends Component
## Creates damage events for other entities
class_name AttackComponent
@export var attack_origin:Node3D
@export var projectile_spawner:ProjectileSpawner
## Attack components *should* only hit these two collision layers
const DEFAULT_MASK = TraceComponent.MASK.GEO | TraceComponent.MASK.HITBOX
var current_attack_data:AttackData
var wishattack:bool = false

func attack_raycast(target:Vector3, mask:int = DEFAULT_MASK) -> void:
	assert(attack_origin != null, "No attack origin set.")
	if not current_attack_data: return
	
	var collision:CollisionObject3D = entity.trace.ray_obj(attack_origin.global_position,target,mask)
	var pos:Vector3 = entity.trace.ray_pos(attack_origin.global_position,target,mask)
	var normal:Vector3 = entity.trace.ray_normal(attack_origin.global_position,target,mask)
	var face_idx:int = entity.trace.ray_face_idx(attack_origin.global_position,target,mask)
	
	if collision is PhysicalBone3D: deal_damage(collision)

func create_projectile(target:Vector3,mask:int = DEFAULT_MASK) -> void:
	assert(attack_origin != null, "No attack origin set.")
	if not current_attack_data: return
	projectile_spawner.projectile_scene = current_attack_data.projectile_scene
	projectile_spawner.spawn(
		{
		"position" : attack_origin.global_position,
		"direction" : attack_origin.global_position.direction_to(target),
		"attacker" : entity.get_path()
		})
	
	#var new_projectile:Projectile = current_attack_data.projectile_scene.instantiate()
	#new_projectile.set_as_top_level(true)
	#entity.add_child(new_projectile)
	#new_projectile.global_position = attack_origin.global_position
	#new_projectile.direction = attack_origin.global_position.direction_to(target)

func deal_damage(collision:CollisionObject3D):
	var data:Dictionary = {}
	var target_entity:Entity = collision.owner
	var bone_idx = collision.get_bone_id()
	if not collision.get_meta_list().is_empty():
		for entry in collision.get_meta_list(): data[entry] = collision.get_meta(entry,0)
	if target_entity.damage:
		target_entity.damage.hurt.rpc(current_attack_data.damage, entity.get_path(), data,bone_idx)
	if target_entity.move:
		var knockback_vector:Vector3 = entity.model_root.global_transform.basis.z if entity.model_root else Vector3.ZERO
		target_entity.move.knockback.rpc(knockback_vector,current_attack_data.knockback)
