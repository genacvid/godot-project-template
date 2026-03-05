@tool
extends Node3D
class_name PlayerSpawn
@export var func_godot_properties:Dictionary
@export var spawn_name:String = "default"
func _func_godot_apply_properties(entity_properties: Dictionary):
	pass
func _func_godot_build_complete():
	self.add_to_group("PlayerSpawn",true)
