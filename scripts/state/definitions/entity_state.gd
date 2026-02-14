extends State
## Base state for all entities, provides easy references to entity components
class_name EntityState
@onready var entity:Entity = owner
@onready var move:MoveComponent = entity.move
@onready var attack:AttackComponent = entity.attack
@onready var damage:DamageComponent = entity.damage
@onready var input:InputComponent = entity.input
@onready var interact:InteractComponent = entity.interact
@onready var navigation:NavigationComponent = entity.navigation
@onready var persist:PersistComponent = entity.persist
@onready var trace:TraceComponent = entity.trace
@onready var sight:SightComponent = entity.sight
@onready var visual_modifier:VisualModifierComponent = entity.visual_modifier
