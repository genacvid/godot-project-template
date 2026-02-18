@tool
extends WorldEnvironment
class_name Stage

func _ready() -> void:
	var map_ref:FuncGodotMap = get_node("FuncGodotMap")
	if not map_ref: print("Map not found"); return
	map_ref.add_to_group("navigation_mesh_source_group",true)
	map_ref.build_complete.connect(func():
		## Create visual modifier
		var visual_modifier := VisualModifierComponent.new()
		visual_modifier.name = "MapVisualModifier"
		map_ref.add_child(visual_modifier,true)
		visual_modifier.owner = get_tree().edited_scene_root
		for mesh_instance in map_ref.find_children("*_mesh_instance","MeshInstance3D",true):
			visual_modifier.target_meshes.append(mesh_instance)
		## Create navigation regions
		for layer_idx in range(1,32):
			var layer_name:String = ProjectSettings.get("layer_names/3d_navigation/layer_" + str(layer_idx))
			if not layer_name.is_empty():
				## create nav region nodes
				var navigation_region := NavigationRegion3D.new()
				map_ref.add_child(navigation_region)
				navigation_region.owner = get_tree().edited_scene_root
				navigation_region.name = layer_name + "NavigationRegion"
				
				## configure nav mesh
				var navigation_mesh := NavigationMesh.new()
				navigation_region.navigation_mesh = navigation_mesh
				navigation_mesh.geometry_source_geometry_mode = NavigationMesh.SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
				var agent_size:float = ProjectSettings.get("global/small_agent_size")
				if layer_name.contains("Small"): agent_size = ProjectSettings.get("global/small_agent_size")
				elif layer_name.contains("Medium"): agent_size = ProjectSettings.get("global/medium_agent_size")
				elif layer_name.contains("Large"): agent_size = ProjectSettings.get("global/large_agent_size")
				navigation_mesh.cell_size = agent_size
				
				## bake nav mesh
				navigation_region.bake_navigation_mesh()
		,CONNECT_PERSIST)
