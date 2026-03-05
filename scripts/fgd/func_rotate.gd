@tool
extends CharacterBody3D
class_name Rotate
@export var func_godot_properties:Dictionary

@export var direction:Vector3
@export var speed:float
@export var start_moving:bool

func _func_godot_apply_properties(entity_properties: Dictionary):
	direction = entity_properties["direction"]
	speed = entity_properties["speed"]
	start_moving = entity_properties["start_moving"]
	move = true
func _ready() -> void:
	move = true
var move:bool = false
func _physics_process(delta: float) -> void:
	if move:
		self.rotate_object_local(direction.normalized(), deg_to_rad(speed) * get_physics_process_delta_time())
