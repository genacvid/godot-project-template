@tool
extends AnimatableBody3D
class_name Mover
@export var func_godot_properties:Dictionary

@export var direction:Vector3
@export var speed:float
@export var one_shot:bool
@export var start_moving:bool
@export var delay:float

var move:bool = true
const INVERSE = -1
func _func_godot_apply_properties(entity_properties: Dictionary):
	sync_to_physics = false
var ceiling_detect:Entity
func _physics_process(delta: float) -> void:
	if move:
		var collision = move_and_collide(direction * speed * delta)
		if collision:
			if collision.get_collider(0) is Entity:
				var entity = collision.get_collider(0)
				entity.velocity += direction * speed
				if test_move(self.transform,direction * speed * delta,collision):
					match direction:
						Vector3.DOWN:
							if entity.is_on_floor():
								impact()
						Vector3.UP:
							self.set_collision_mask_value(2,false)
							ceiling_detect = entity
			else:
				impact()
			if one_shot:
				speed = 0
		if direction == Vector3.UP and is_instance_valid(ceiling_detect) and ceiling_detect.is_on_ceiling():
			impact()

func impact():
	self.set_collision_mask_value(2,true)
	direction *= INVERSE
	if delay > 0 and not is_instance_valid(ceiling_detect):
		move = false
		await get_tree().create_timer(delay).timeout
		move = true
	if is_instance_valid(ceiling_detect):
		ceiling_detect = null
