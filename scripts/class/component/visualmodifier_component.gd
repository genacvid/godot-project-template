@icon("res://resources/gui/interp.svg")
extends Node
## Modifies material and animation properties at runtime
class_name VisualModifierComponent

@export var target_animation_players:Array[AnimationPlayer]
@export var target_meshes:Array[MeshInstance3D]
const PSX_SHADER = preload("uid://d1lc8w5pwac7s")

func _ready() -> void:
	if Engine.is_editor_hint(): return
	Settings.video_settings_changed.connect(set_texture_filter)
	Settings.video_settings_changed.connect(set_animation_interpolation)
	Settings.video_settings_changed.connect(set_psx_shader_parameters)
	## Apply psx shader if global variable is set, otherwise skip this
	if not Settings.use_psx_shader: return
	for mesh_instance:MeshInstance3D in target_meshes:
		var mesh:Mesh = mesh_instance.mesh
		for surface_idx:int in mesh_instance.get_surface_override_material_count():
			var psx_shader_override:ShaderMaterial = PSX_SHADER.duplicate()
			mesh_instance.set_surface_override_material(surface_idx,psx_shader_override)
			if not mesh.surface_get_material(surface_idx): return
			var texture_ref = mesh.surface_get_material(surface_idx).albedo_texture
			psx_shader_override.set_shader_parameter("albedo",texture_ref)
			psx_shader_override.set_shader_parameter("albedo_filtered",texture_ref)
## This functions changes the filtering of textures. For crisp, pixelated
## textures, we set filtering to nearest. For smooth, interpolated textures,
## we set filtering to linear. If you don't like how jagged textures look
## from a distance, change TEXTURE_FILTER_NEAREST to TEXTURE_FILTER_NEAREST_WITH_MIPMAPS_ANISOTROPIC
func set_texture_filter() -> void:
	var toggle = bool(Settings.video_settings[&"texture_quality"])
	for mesh_instance:MeshInstance3D in target_meshes:
		var mesh = mesh_instance.mesh
		for surface in mesh.get_surface_count():
			var material:StandardMaterial3D = mesh.surface_get_material(surface)
			if toggle:
				material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
			else:
				material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST

## This function toggles interpolation between keyframes in an animation.
## To achieve the desired effect of "choppy" animations, reimport your model
## with a low animation frame rate (12 FPS is ideal). How the animation is keyed
## out in Blender does not matter, as Godot makes its own keyframes based on
## the import frame rate.
func set_animation_interpolation() -> void:
	var toggle = bool(Settings.video_settings[&"animation_quality"])
	var quality = Animation.InterpolationType.INTERPOLATION_LINEAR if toggle else Animation.InterpolationType.INTERPOLATION_NEAREST
	for animation_player:AnimationPlayer in target_animation_players:
		for animation_name:String in animation_player.get_animation_list():
			var current_animation:Animation = animation_player.get_animation(animation_name)
			for track:int in current_animation.get_track_count():
				current_animation.track_set_interpolation_type(track,quality)

func set_psx_shader_parameters():
	if not Settings.use_psx_shader: return
	for mesh_instance:MeshInstance3D in target_meshes:
		for surface_idx:int in mesh_instance.get_surface_override_material_count():
			var material = mesh_instance.get_surface_override_material(surface_idx)
			if material is ShaderMaterial:
				material.set_shader_parameter("filtering",bool(Settings.video_settings[&"texture_quality"]))
				var jitter = 0.5 if bool(Settings.video_settings[&"model_quality"]) else 0.0
				material.set_shader_parameter("jitter",jitter)
				#material.set_shader_parameter("affine_texture_mapping",bool(Settings.video_settings[&"model_quality"]))
				material.set_shader_parameter("affine_mapping",false)
				
