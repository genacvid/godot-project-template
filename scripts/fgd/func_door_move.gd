@tool
extends AnimatableBody3D
class_name FuncDoorMove
@export var func_godot_properties:Dictionary
@export var direction:Vector3
@export var speed:float = 1.0
@export var key:String = ""
@onready var original_position = self.global_position
var is_open:bool = false
var moving:bool = false
func _func_godot_apply_properties(entity_properties: Dictionary):
	pass
func _func_godot_build_complete():
	pass
func open():
	if moving: return
	moving = true
	if is_open:
		moving = false
		close(); return;
	await create_tween().tween_property(self,"global_position",self.global_position + direction,speed).from(original_position).finished
	moving = false
	is_open = true
func close():
	if moving: return
	moving = true
	await create_tween().tween_property(self,"global_position",original_position,speed).from(self.global_position).finished
	moving = false
	is_open = false
