extends Resource
class_name AttackData
@export_enum("Raycast","Projectile","Melee") var attack_type:int
@export var damage:float = 0.0
@export var knockback:float = 0.0
@export var projectile_speed:float = 10.0
@export var projectile_scene:PackedScene
