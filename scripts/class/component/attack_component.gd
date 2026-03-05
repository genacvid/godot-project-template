@icon("res://resources/gui/attack.svg")
extends Component
## Creates damage events for other entities
class_name AttackComponent
@export var attack_origin:Node3D
@export var projectile_spawner:ProjectileSpawner
## Attack components *should* only hit these two collision layers
const DEFAULT_MASK = 1 | 3
@export var current_weapon:Weapon
var current_attack_data:AttackData
var wishattack:bool = false
var wishreload:bool = false
var can_attack:bool = false
var reloading:bool = false
var bursting:bool = false
var out_of_ammo:bool = false
var attack_timer:float = 0.0
var aim_pos:Vector3
var spread:float = 0.0
var spread_mod:float = 1.0
const MAX_SPREAD_MOD = 1.2
signal attacked
signal reloaded
const BURST_TIMER = 0.12
func _physics_process(delta: float) -> void:
	## Check if weapon is valid
	if not current_weapon: return
	if current_weapon:
		current_attack_data = current_weapon.attack_data
	else:
		current_attack_data = null
		return
	if reloading: return
	spread_mod = 1.0 if entity.is_on_floor() else MAX_SPREAD_MOD
	spread -= (current_attack_data.spread_decay / spread_mod * delta)
	spread = clamp(spread,0.0,current_attack_data.spread_maximum * spread_mod)
	## Handle attack firing
	var fire_rate:float = (1.0 / current_attack_data.firerate) * 60.0 ## converted from rounds per minute
	if wishattack and can_attack:
		if current_attack_data.firemode == AttackData.MODE_SEMI or current_attack_data.firemode == AttackData.MODE_AUTO:
			if out_of_ammo: return
			attacked.emit()
		elif current_attack_data.firemode == AttackData.MODE_BURST and not bursting:
			for _i in range(3):
				if out_of_ammo: return
				bursting = true
				await get_tree().create_timer(BURST_TIMER).timeout
				attacked.emit()
		can_attack = false
		
	## Handle attack cooldown
	if not can_attack:
		attack_timer += delta
	if current_attack_data.firemode == AttackData.MODE_SEMI or current_attack_data.firemode == AttackData.MODE_BURST:
		if not wishattack and not can_attack and attack_timer >= fire_rate:
			can_attack = true
			attack_timer = 0.0
	if current_attack_data.firemode == AttackData.MODE_AUTO:
		if not can_attack and attack_timer >= fire_rate:
			can_attack = true
			attack_timer = 0.0
	if wishreload:
		reloaded.emit()
func _on_attacked() -> void:
	if entity is Player:
		var recoil:float = current_attack_data.recoil
		var recovery:float = current_attack_data.recoil_recovery
		create_tween().tween_property(
			entity.camera,"rotation_degrees:x",
			entity.camera.rotation_degrees.x,recovery
		).from(entity.camera.rotation_degrees.x + recoil).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	match current_attack_data.attack_type:
		AttackData.TYPE_RAY:
			attack_raycast()
func attack_raycast(mask:int = DEFAULT_MASK) -> void:
	assert(attack_origin != null, "No attack origin set.")
	if not current_attack_data: return
	var offset = Vector3(randf_range(-spread,spread),randf_range(-spread,spread),randf_range(-spread,spread))
	var direction = attack_origin.global_position.direction_to(aim_pos + offset) * 4096.0
	var collision:CollisionObject3D = entity.trace.ray_obj(attack_origin.global_position,direction,mask)
	var pos:Vector3 = entity.trace.ray_pos(attack_origin.global_position,direction,mask)
	var normal:Vector3 = entity.trace.ray_normal(attack_origin.global_position,direction,mask)
	var face_idx:int = entity.trace.ray_face_idx(attack_origin.global_position,direction,mask)
	Debug.line(attack_origin.global_position,pos,Color.PURPLE,1.0)
	Debug.box(pos,1.0,Vector3.ONE*0.1,Color.PURPLE)
	if collision is PhysicalBone3D:
		deal_damage(collision)
	spread += current_attack_data.spread_increase
	
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
