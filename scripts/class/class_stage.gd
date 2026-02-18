@tool
extends WorldEnvironment
class_name Stage

func _ready() -> void:
	var map_ref:FuncGodotMap = get_node("FuncGodotMap")
	map_ref.build_complete.connect(func():
		## Create visual modifier
		var visual_modifier := VisualModifierComponent.new()
		visual_modifier.name = "MapVisualModifier"
		map_ref.add_child(visual_modifier,true)
		visual_modifier.owner = get_tree().edited_scene_root
		for mesh_instance in map_ref.find_children("*_mesh_instance","MeshInstance3D",true):
			visual_modifier.target_meshes.append(mesh_instance)
		## TODO: Create navigation meshes
		
		,CONNECT_PERSIST)		
