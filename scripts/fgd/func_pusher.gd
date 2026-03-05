@tool
extends StaticBody3D
@export var direction:Vector3
@export var speed:float
@export var animate:bool = false
@export var mesh_instance:MeshInstance3D
func _func_godot_apply_properties(entity_properties: Dictionary):
	self.constant_linear_velocity = (direction * speed)
	if animate:
		mesh_instance = self.get_child(0)
		mesh_instance.set_surface_override_material(0,mesh_instance.mesh.surface_get_material(0).duplicate())
func _process(delta: float) -> void:
	if animate:
		var material = self.get_child(0).get_surface_override_material(0) as StandardMaterial3D
		material.uv1_offset.x -= direction.z / 64
		material.uv1_offset.z -= direction.x / 64
		material.uv1_offset.x = wrapf(material.uv1_offset.x,0.0,1.0)
		material.uv1_offset.z = wrapf(material.uv1_offset.z,0.0,1.0)
