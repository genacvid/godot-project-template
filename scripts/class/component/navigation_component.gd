@icon("res://resources/gui/navigation.svg")
extends Component
## Processes entity navigation
class_name NavigationComponent

@export var agent:NavigationAgent3D
@export var wander_distance:float = 10.0
var distance_to_goal:float
var target_entity:Entity
@onready var home_position:Vector3 = entity.global_position
func update() -> void:
	distance_to_goal = self.global_position.distance_to(agent.get_final_position())
	var nav_command = Vector2(
		agent.get_next_path_position().x - self.global_position.x,
		agent.get_next_path_position().z - self.global_position.z)
	if distance_to_goal > agent.target_desired_distance:
		entity.move.wishdir = Vector3(nav_command.x,0,nav_command.y).normalized()
	else: entity.move.wishdir = Vector3.ZERO

func set_random_location() -> void:
	agent.set_target_position(Vector3(
		home_position.x + randf_range(-wander_distance,wander_distance),
		home_position.y,
		home_position.z + randf_range(-wander_distance,wander_distance)
	))
