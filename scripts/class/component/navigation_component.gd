@icon("res://resources/gui/navigation.svg")
extends Component
## Processes entity navigation
class_name NavigationComponent

@export var agent:NavigationAgent3D
@export var wander_distance:float = 10.0
var distance_to_goal:float
var target_entity:Entity
@onready var home_position:Vector3 = entity.global_position
func _ready() -> void:
	agent.velocity_computed.connect(func(safe_velocity:Vector3):entity.velocity += safe_velocity)
	agent.link_reached.connect(func(details:Dictionary):
		if "Crouch" in details["owner"].name:
			entity.move.wishcrouch = true
		if "Jump" in details["owner"].name:
			if entity.move.wishjump: return
			var stored_jump_vel = entity.move.jump_impulse
			entity.move.jump_impulse += abs(details["link_entry_position"].y + details["link_exit_position"].y) * 2
			entity.move.wishjump = true
			await get_tree().create_timer(0.1).timeout
			entity.move.wishjump = false
			entity.move.jump_impulse = stored_jump_vel
		)
func update() -> void:
	distance_to_goal = agent.distance_to_target()
	var nav_command = Vector2(
		agent.get_next_path_position().x - entity.global_position.x,
		agent.get_next_path_position().z - entity.global_position.z)
	if distance_to_goal > agent.target_desired_distance:
		entity.move.wishdir = Vector3(nav_command.x,0,nav_command.y).normalized()
	else:
		if entity.move.wishcrouch: entity.move.wishcrouch = false
		entity.move.wishdir = Vector3.ZERO

func set_random_location() -> void:
	agent.set_target_position(Vector3(
		home_position.x + randf_range(-wander_distance,wander_distance),
		home_position.y,
		home_position.z + randf_range(-wander_distance,wander_distance)
	))
