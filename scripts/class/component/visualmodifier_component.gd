@icon("res://resources/gui/interp.svg")
extends Component
## Modifies material and animation properties at runtime
class_name VisualModifierComponent

@export var target_animation_players:Array[AnimationPlayer]
@export var target_meshes:Array[MeshInstance3D]
