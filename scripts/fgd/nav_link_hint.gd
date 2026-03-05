@tool
extends NavigationLink3D
class_name NavLinkHint
@export var func_godot_properties:Dictionary
var key:String = ""
func _func_godot_apply_properties(entity_properties: Dictionary):
	self.name = "HintLink"
func _func_godot_build_complete():
	for exit_node:NavExit in get_tree().get_nodes_in_group("NavExit"):
		if exit_node.key == self.key:
			end_position.x = self.global_position.x - exit_node.global_position.x
			end_position.z = self.global_position.z - exit_node.global_position.z
			end_position.y = self.global_position.y + exit_node.global_position.y
