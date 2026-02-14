@icon("res://resources/gui/move.svg")
extends Component
## Enables basic entity movement
class_name MoveComponent

@export_category("Definitions")
@export var max_ground_speed:float = 5.0
@onready var current_ground_speed:float = max_ground_speed
@export var max_air_speed:float = 5.0
@onready var current_air_speed:float = max_air_speed
@export var max_accel:float = 1.0
@onready var current_accel:float = max_accel
@export var max_air_accel:float = 1.0
@onready var current_air_accel:float = max_air_accel
@export var max_friction:float = 1.0
@onready var current_friction:float = max_friction
@export var jump_impulse:float = 3.0
@export var gravity:float = 9.8

@onready var entity_standing_size:Vector3 = entity.collision.shape.size
@onready var entity_standing_pos:Vector3 = entity.collision.position
@onready var entity_crouching_size:Vector3 = entity.collision.shape.size
@onready var entity_crouching_pos:Vector3 = entity.collision.position/2
@onready var camera_root_standing_pos:float = entity.camera_root.position.y
@onready var camera_root_crouching_pos:float = entity.camera_root.position.y / 2

@export_category("Node Paths")
@export var crouchcast:ShapeCast3D
@export var staircast_up:ShapeCast3D
@export var staircast_down:RayCast3D

## Movement states
var wishdir:Vector3
var wishjump:bool
var wishrun:bool
var wishcrouch:bool
var can_move:bool = true
var vertical_velocity:float = 0.0
var terminal_velocity = gravity * -5.0

const MAX_STEP_MARGIN = 0.01
const MAX_STEP_HEIGHT = 0.25 + MAX_STEP_MARGIN ## 4 TB Units
const HORIZONTAL_VECTOR = Vector3(1,0,1)

func _ready() -> void:
	entity_crouching_size.y /= 2

func update(delta:float):
	if not is_multiplayer_authority(): return
	var h_vel = Vector3(entity.velocity.x,0,entity.velocity.z)
	## accel based on wishdir
	if wishdir:
		h_vel = h_vel.lerp(
		## lerp to max speed
		(wishdir * max_ground_speed) if entity.is_on_floor() else (wishdir * max_air_speed),
		## based on accel
		(current_accel * delta) if entity.is_on_floor() else (current_air_accel * delta))
	## apply friction w/ no inputs
	else: h_vel = h_vel.lerp(Vector3.ZERO,(current_friction * delta))
	## apply gravity
	## apply velocities, then move_and_slide
	if not entity.is_on_floor():
		vertical_velocity -= gravity * delta
	entity.velocity.x = h_vel.x
	entity.velocity.z = h_vel.z
	entity.velocity.y = vertical_velocity
	crouch(wishcrouch)
	entity.move_and_slide()

func jump(): vertical_velocity += jump_impulse

## TODO: This expects the entity collision to be a box, refactor to support capsules and cylinders
func crouch(toggle:bool):
	if crouchcast.is_colliding(): toggle = false
	entity.collision.shape.size = entity_crouching_size if toggle else entity_standing_size
	entity.collision.position = entity_crouching_pos if toggle else entity_standing_pos
	entity.camera_root.position.y = camera_root_crouching_pos if toggle else camera_root_standing_pos

func stairsolve_up(delta):
	var expected_move_motion = wishdir * HORIZONTAL_VECTOR * delta
	var clearance = entity.global_transform.translated(expected_move_motion + Vector3(0, MAX_STEP_HEIGHT * 2, 0))
	var collision_result = KinematicCollision3D.new()
	if entity.test_move(clearance,Vector3(0, -MAX_STEP_HEIGHT * 2, 0),collision_result):
		var step_height = ((clearance.origin + collision_result.get_travel() - entity.global_position)).y
		if step_height > MAX_STEP_HEIGHT or step_height <= MAX_STEP_MARGIN or (collision_result.get_position(0) - entity.global_position).y > MAX_STEP_HEIGHT:
			return false
		if entity.staircast_up.is_colliding():
			entity.global_position = clearance.origin + collision_result.get_travel()
			entity.apply_floor_snap()
			return true
	return false

func stairsolve_down():
	staircast_down.force_raycast_update()
	var floor_check:bool = staircast_down.is_colliding() and not stairsolve_check_angle(staircast_down.get_collision_normal())
	if floor_check:
		var collision_result = KinematicCollision3D.new()
		if entity.test_move(entity.global_transform, Vector3(0,-MAX_STEP_HEIGHT,0), collision_result):
			var step_height = collision_result.get_travel().y
			entity.global_position.y += step_height
			entity.apply_floor_snap()
			return true
	return false

func stairsolve_check_angle(normal:Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > entity.floor_max_angle

@rpc("any_peer")
func knockback(vector:Vector3,factor:float=1.0) -> void:
	entity.velocity -= vector * factor
	vertical_velocity -= factor
