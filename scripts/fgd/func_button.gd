@tool
extends StaticBody3D
class_name FuncButton
@export var func_godot_properties:Dictionary
@export var target:String = ""
@export var functions:String = ""
signal pressed
func _func_godot_apply_properties(entity_properties: Dictionary):
	pass
func _func_godot_build_complete():
	for target_node in get_tree().get_nodes_in_group("Target"):
		if "key" in target_node:
			if target_node.key == target:
				for function in functions.rsplit(","):
					if target_node.has_method(function):
						var callable = Callable(target_node,function)
						self.connect("pressed",callable,CONNECT_PERSIST)
