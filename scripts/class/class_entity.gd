extends CharacterBody3D
## Base entity, holds references to components
class_name Entity

@export_category("Components")
@export var move:MoveComponent
@export var attack:AttackComponent
@export var damage:DamageComponent
@export var navigation:NavigationComponent
@export var interact:InteractComponent
@export var input:InputComponent
@export var persist:PersistComponent
@export var trace:TraceComponent
@export var sight:SightComponent

@export_category("Node Paths")
## The root of the scene representing the model, typically an instanced glb
@export var model_root:Node3D
## The model's animation player
@export var animation_player:AnimationPlayer
## Transform for the player's camera pivot
@export var camera_root:RemoteTransform3D
## Geometry collision for the entity
@export var collision:CollisionShape3D
## Various state machines that control the entity
@export var state_machines:Array[StateMachine]
## Multiplayer spawner for synchronizing node instantiation
## Nodes created through the spawner are owned by the parent entity
@export var spawner:MultiplayerSpawner
## Multiplayer synchronizer shares properties across clients
@export var synchronizer:MultiplayerSynchronizer
