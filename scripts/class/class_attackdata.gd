extends Resource
class_name AttackData
enum{TYPE_RAY,TYPE_PROJECTILE,TYPE_MELEE}
@export_enum("Raycast","Projectile","Melee") var attack_type:int
@export var damage:float = 20.0
@export var knockback:float = 0.0
@export var distance:float = 10.0
@export var firerate:float = 300.0
@export var burstrate:float = 0.06
enum{MODE_SEMI,MODE_BURST,MODE_AUTO}
@export_enum("Semi","Burst","Auto") var firemode:int = 0
@export var spread_increase:float = 0.2
@export var spread_decay:float = 0.5
@export var spread_maximum:float = 0.15
@export var recoil:float = 1.0
@export var recoil_recovery:float = 0.3
@export var capacity:int = 10
@export var max_capacity:int = 10
@export var reserve:int = 1
@export var projectile_scene:PackedScene
