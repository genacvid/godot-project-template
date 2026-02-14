@icon("res://resources/gui/move.svg")
extends MoveComponent
## Enables Quake-style movement, intended for players
## Implementation provided by axel37
class_name QMoveComponent
var accelerate_return = Vector3.ZERO

func calculate_accelerate(
	input_wishdir:Vector3,
	input_velocity: Vector3, 
	input_accel: float, 
	input_speed: float,
	delta: float)-> Vector3:
	# Current speed is calculated by projecting our velocity onto wishdir.
	# We can thus manipulate our wishdir to trick the engine into thinking we're going slower than we actually are, allowing us to accelerate further.
	var current_speed: float = input_velocity.dot(input_wishdir)
	# Next, we calculate the speed to be added for the next frame.
	# If our current speed is low enough, we will add the max acceleration.
	# If we're going too fast, our acceleration will be reduced (until it evenutually hits 0, where we don't add any more speed).

	var add_speed: float = clamp(input_speed - current_speed, 0, input_accel * delta)
	# Put the new velocity in a variable, so the vector can be displayed.
	accelerate_return = input_velocity + input_wishdir * add_speed
	
	return accelerate_return

func calculate_friction(
	input_velocity: Vector3, 
	delta: float)-> Vector3:
	var speed: float = input_velocity.length()
	var scaled_velocity: Vector3
	# Check that speed isn't 0, this is to avoid divide by zero errors
	if speed != 0:
		var drop = speed * current_friction * delta # Amount of speed to be reduced by friction
		# ((max(speed - drop, 0) / speed) will return a number between 0 and 1, this is our speed multiplier from friction
		# The max() is there to avoid anything from happening in the case where the user sets friction to a negative value
		scaled_velocity = input_velocity * max(speed - drop, 0) / speed
	# Stop altogether if we're going too slow to notice
	if speed < 0.1:
		return scaled_velocity * 0
	return scaled_velocity

func move_ground(
	input_velocity: Vector3, 
	delta: float)-> void:
	
	# We first work on only on the horizontal components of our current velocity
	var nextVelocity: Vector3 = Vector3.ZERO
	nextVelocity.z = input_velocity.z
	nextVelocity.x = input_velocity.x
	nextVelocity = calculate_friction(entity.velocity, delta) #Scale down velocity
	nextVelocity = calculate_accelerate(wishdir, nextVelocity, current_accel, max_ground_speed, delta)
	# Then get back our vertical component, and move the entity
	nextVelocity.y = vertical_velocity
	entity.velocity = nextVelocity
	entity.move_and_slide()

func move_air(
	input_velocity: Vector3, 
	delta: float)-> void:
	# We first work on only on the horizontal components of our current velocity

	var nextVelocity: Vector3 = Vector3.ZERO
	nextVelocity.x = input_velocity.x
	nextVelocity.z = input_velocity.z
	nextVelocity = calculate_accelerate(wishdir, nextVelocity, current_air_accel, max_air_speed, delta)

	# Apply gravity
	vertical_velocity -= gravity * delta if vertical_velocity >= terminal_velocity else 0.0
	# Then get back our vertical component, and move the entity
	nextVelocity.y = vertical_velocity
	entity.velocity = nextVelocity
	
	entity.move_and_slide()

func update(delta:float):
	if not is_multiplayer_authority(): return
	crouch(wishcrouch)
	if entity.is_on_floor():
		stairsolve_up(delta)
		move_ground(entity.velocity,delta)
	else:
		move_air(entity.velocity,delta)
