extends QMoveComponent
class_name BiomechMoveComponent
@onready var biomech = owner as Biomech
@export_category("Biomech Movement Variables")
## How quickly speed and acceleration reach their top values while boosters are active
@export var BOOST_SPEED_GAIN = 7.0
@export var BOOST_ACCEL_GAIN = 7.0

## How quickly speed and acceleration decay towards zero while boosters are active
@export var BOOST_SPEED_DECAY = 0.75
@export var BOOST_ACCEL_DECAY = 0.5

## Maximum horizontal speed and acceleration values for normal boosting
@export var BOOST_MAX_SPEED = 25.5
@export var BOOST_MAX_ACCEL = 100.0

## How quickly speed and acceleration decay towards zero while boosters are inactive
@export var WALK_MAX_SPEED = 4.0
@export var WALK_MAX_ACCEL = 40.0

## Modifiers for speed decay on the ground and in the air. Aerial speed bleeds much slower than ground speed.
@export var GROUND_DECAY_MOD = 2.0
@export var AIR_DECAY_MOD = 1.0
@export var AIR_PENALTY = 0.85

## Amount of time Burst is active for. The longer this is, the higher the distance traveled
@export var BURST_INJECTION_TIME = 0.16
## Maximum amount of force to build up towards while Burst is active
@export var BURST_FORCE = 10.0
## How quickly Burst velocity decays after Burst Injection has finished. TODO: This will be influenced by Aerodynamics
@export var BURST_DECAY = 0.5
## Time to wait between engaging Burst again. TODO: Add chainboosting, making different directions exclusive from each other
@export var BURST_COOLDOWN = 0.5
## Amount of vertical velocity lost when Burst is activated, dampening one's fall
@export var BURST_VERTICAL_DAMPENING = 4
## Camera drag variables for giving a feel of momentum
@export var CAMERA_TRACKING_DRAG = 4
@export var CAMERA_TRACKING_DEFAULT = 7.5
@onready var camera_tracking_speed = CAMERA_TRACKING_DEFAULT
## Amount of lift velocity applied per frame while active
@export var LIFT_STRENGTH = 1.5
## Maximum amount of lift power achievable
@export var LIFT_MAX_POWER = 1.75

var wishburst:bool = false
var can_burst:bool = true
var perform_jump_timer:float = 0.0
var queue_jump:bool = false
var max_speed:float = 0.0
var air_friction:float = 0.5
var accel:float = 0.0
var burst_velocity:Vector3 = Vector3.ZERO
var vertical_lift:float = 0.0
signal burst_thrusters_activated
func move_burst() -> void:
	if not can_burst: return
	burst_thrusters_activated.emit()
	if vertical_velocity < 0.0 : vertical_velocity /= BURST_VERTICAL_DAMPENING
	camera_tracking_speed /= CAMERA_TRACKING_DRAG
	create_tween().tween_property(self,"burst_velocity:x",wishdir.x * BURST_FORCE,BURST_INJECTION_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	create_tween().tween_property(self,"burst_velocity:z",wishdir.z * BURST_FORCE,BURST_INJECTION_TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	can_burst = false
	await get_tree().create_timer(BURST_INJECTION_TIME).timeout
	## Tween tracking and velocity back to their original values and await for cooldown to finish
	create_tween().tween_property(self,"camera_tracking_speed",CAMERA_TRACKING_DEFAULT,BURST_INJECTION_TIME)
	create_tween().tween_property(self,"burst_velocity",Vector3.ZERO,BURST_DECAY)
	await get_tree().create_timer(BURST_COOLDOWN).timeout
	can_burst = true
func move_ground(
	input_velocity: Vector3, 
	delta: float)-> void:
	## Booster logic
	if wishjump:
		#max_speed = 10.0
		max_speed = lerp(max_speed,BOOST_MAX_SPEED,delta*BOOST_SPEED_GAIN)
		accel = lerp(accel,BOOST_MAX_ACCEL,delta*BOOST_ACCEL_GAIN)
		#accel = 75.0
	else:
		max_speed = lerp(max_speed,WALK_MAX_SPEED,delta*BOOST_SPEED_DECAY*GROUND_DECAY_MOD)
		accel = lerp(accel,WALK_MAX_ACCEL,delta*BOOST_ACCEL_DECAY*GROUND_DECAY_MOD)
		#accel = 50.0
	# We first work on only on the horizontal components of our current velocity
	var nextVelocity: Vector3 = Vector3.ZERO
	nextVelocity.x = input_velocity.x
	nextVelocity.z = input_velocity.z
	nextVelocity.x = calculate_friction(nextVelocity, delta,false).x #Scale down velocity
	nextVelocity.z = calculate_friction(nextVelocity, delta,false).z #Scale down velocity
	nextVelocity = calculate_accelerate(wishdir, nextVelocity, accel, max_speed, delta)
	# Then get back our vertical component, and move the player
	nextVelocity.y = vertical_velocity
	nextVelocity = nextVelocity.limit_length(max_speed)
	entity.velocity = nextVelocity + burst_velocity
	entity.move_and_slide()
func move_air(
	input_velocity: Vector3, 
	delta: float)-> void:
	# We first work on only on the horizontal components of our current velocity
	if wishjump:
		#max_speed = 10.0
		vertical_lift += LIFT_STRENGTH * delta
		vertical_lift = clamp(vertical_lift,0.0,LIFT_MAX_POWER)
		max_speed = lerp(max_speed,BOOST_MAX_SPEED * AIR_PENALTY,delta*BOOST_SPEED_GAIN)
		accel = lerp(accel,BOOST_MAX_ACCEL,delta*BOOST_ACCEL_GAIN)
		vertical_velocity += vertical_lift
		vertical_velocity = clamp(vertical_velocity,-20.0,6.0)
		#accel = 75.0
	else:
		vertical_lift = 0.0
		max_speed = lerp(max_speed,WALK_MAX_SPEED,delta*BOOST_SPEED_DECAY * AIR_DECAY_MOD)
		accel = lerp(accel,WALK_MAX_ACCEL,delta*BOOST_ACCEL_DECAY * AIR_DECAY_MOD)
		#accel = 50.0
	var nextVelocity: Vector3 = Vector3.ZERO
	nextVelocity.x = input_velocity.x
	nextVelocity.z = input_velocity.z
	nextVelocity.x = calculate_friction(nextVelocity,delta,true).x
	nextVelocity.z = calculate_friction(nextVelocity,delta,true).z
	nextVelocity = calculate_accelerate(wishdir, nextVelocity, accel, max_speed, delta)
	# Apply gravity
	vertical_velocity -= (fall_speed + gravity) * delta if vertical_velocity >= terminal_velocity else 0.0
	# Then get back our vertical component, and move the player
	nextVelocity = nextVelocity.limit_length(max_speed)
	nextVelocity.y = vertical_velocity
	entity.velocity = nextVelocity + burst_velocity
	entity.move_and_slide()
func calculate_friction(
	input_velocity: Vector3, 
	delta: float,
	aerial:bool=false)-> Vector3:
	var speed: float = input_velocity.length()
	var scaled_velocity: Vector3
	# Check that speed isn't 0, this is to avoid divide by zero errors
	if speed != 0:
		var drop = speed * max_friction * delta # Amount of speed to be reduced by friction
		# ((max(speed - drop, 0) / speed) will return a number between 0 and 1, this is our speed multiplier from friction
		# The max() is there to avoid anything from happening in the case where the user sets friction to a negative value
		scaled_velocity = input_velocity * max(speed - drop, 0) / speed
	# Stop altogether if we're going too slow to notice
	if speed < 0.1:
		return scaled_velocity * 0
	return scaled_velocity
func calculate_accelerate(
	input_wishdir: Vector3,
	input_velocity: Vector3, 
	input_accel: float, 
	input_max_speed: float,
	delta: float)-> Vector3:
	# Current speed is calculated by projecting our velocity onto wishdir.
	# We can thus manipulate our wishdir to trick the engine into thinking we're going slower than we actually are, allowing us to accelerate further.
	## Sorry, no fun allowed! We get wishdir's length instead of a dot projection
	## so no funny movement tricks!
	#var current_speed: float = input_velocity.dot(wishdir)
	var current_speed: float = input_wishdir.length()
	# Next, we calculate the speed to be added for the next frame.
	# If our current speed is low enough, we will add the max acceleration.
	# If we're going too fast, our acceleration will be reduced (until it evenutually hits 0, where we don't add any more speed).

	var add_speed: float = clamp(input_max_speed - current_speed, 0, input_accel * delta)
	# Put the new velocity in a variable, so the vector can be displayed.
	accelerate_return = input_velocity + input_wishdir * add_speed
	
	return accelerate_return
func update(delta:float):
	if not is_multiplayer_authority(): return
	if entity.is_on_ceiling():
		vertical_velocity = 0.0
	if entity.is_on_floor():
		stairsolve_up(delta)
		move_ground(entity.velocity,delta)
	else:
		move_air(entity.velocity,delta)
