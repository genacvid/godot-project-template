@icon("res://resources/gui/input.svg")
extends Component
## Processes player input, allowing player to affect components and states
class_name InputComponent
var localdir:Vector3
@export var camera_rotation:Vector2
## When enabled, holding jump will automatically jump when we hit the ground
@export var auto_jump:bool = true
const MAX_PITCH:float = deg_to_rad(90)
const MOUSE_SENSITIVITY:float = 5

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	## Standard camera controller
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_rotation.y -= event.screen_relative.y * (MOUSE_SENSITIVITY / 1000)
		camera_rotation.x -= event.screen_relative.x * (MOUSE_SENSITIVITY / 1000)
		camera_rotation.y = clamp(camera_rotation.y,-MAX_PITCH,MAX_PITCH)
		rotate_camera()

## This can be called directly to force a camera change after setting camera_rotation
func rotate_camera():
	entity.camera_root.basis = Basis()
	entity.camera_root.rotate_x(camera_rotation.y)
	entity.camera_root.rotate_y(camera_rotation.x)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	if Input.is_action_just_pressed(&"menu"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		Game.hud.pause.show()
	entity.model_root.rotation.y = entity.camera_root.rotation.y
	## get localized direction inputs
	localdir = Vector3(
		Input.get_action_strength(&"move_right") - Input.get_action_strength(&"move_left"), 0,
		Input.get_action_strength(&"move_backwards") - Input.get_action_strength(&"move_forwards"))
	## rotate localized input around the camera's vertical axis
	if entity.move.can_move:
		entity.move.wishdir = localdir.rotated(Vector3.UP, entity.camera_root.global_transform.basis.get_euler().y).normalized()
	else: entity.move.wishdir = Vector3.ZERO
	
	## set movement states
	entity.move.wishjump = Input.is_action_just_pressed(&"jump") if not auto_jump else Input.is_action_pressed(&"jump")
	entity.move.wishcrouch = Input.is_action_pressed(&"crouch")
	entity.move.wishrun = Input.is_action_just_pressed(&"run")
	entity.attack.wishattack = Input.is_action_pressed("attack")

	## set inventory states
	if Input.is_action_just_pressed("switch_slot_1"): entity.inventory.switch_slot(1)
	if Input.is_action_just_pressed("switch_slot_2"): entity.inventory.switch_slot(2)
	if Input.is_action_just_pressed("switch_slot_3"): entity.inventory.switch_slot(3)
	if Input.is_action_just_pressed("switch_slot_4"): entity.inventory.switch_slot(4)
	if Input.is_action_just_pressed("switch_slot_5"): entity.inventory.switch_slot(5)

	## set aim pos based on screenspace center
	if entity is Player:
		var mouse_pos:Vector2 = get_window().get_mouse_position()
		var from = entity.camera.project_ray_origin(mouse_pos)
		var to = entity.camera.project_position(mouse_pos,entity.camera.far)
		var pos = entity.trace.ray_pos(from,to,TraceComponent.MASK.GEO)
		entity.attack.aim_pos = pos
		Debug.sphere(pos)
