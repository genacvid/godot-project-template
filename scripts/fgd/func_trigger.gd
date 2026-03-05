@tool
extends Area3D
class_name FuncTrigger
@export var func_godot_properties:Dictionary
func _func_godot_apply_properties(entity_properties: Dictionary):
	pass
func _func_godot_build_complete():
	body_entered.connect(on_body_entered,CONNECT_PERSIST)
	body_exited.connect(on_body_exited,CONNECT_PERSIST)
	self.set_collision_layer_value(TraceComponent.MASK.GEO,false)
	self.set_collision_layer_value(TraceComponent.MASK.ENTITY,true)
func on_body_entered(body) -> void:
	pass
func on_body_exited(body) -> void:
	pass
