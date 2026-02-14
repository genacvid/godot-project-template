extends Node
## Building blocks for entity functionality
class_name Component
@onready var entity:Entity = owner
func _ready() -> void: assert(owner is Entity,"Component attached to non-Entity")
