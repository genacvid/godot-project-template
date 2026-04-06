extends Entity
class_name Biomech
@onready var camera: Camera3D = $CameraPivot/Camera
@onready var hud: HUD = $HUD
@onready var camera_pivot: SpringArm3D = $CameraPivot
@onready var mech_move = move as BiomechMoveComponent
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	if not is_multiplayer_authority(): return
	Game.player = self
	Game.camera = camera
	Game.hud = hud
	hud.show()
	camera.current = true
	for player_spawn:PlayerSpawn in get_tree().get_nodes_in_group("PlayerSpawn"):
		if player_spawn.spawn_name == "default":
			self.global_position = player_spawn.global_position
			input.camera_rotation.x = player_spawn.rotation.x
			model_root.rotation.x = player_spawn.rotation.x
			self.reset_physics_interpolation()
			input.rotate_camera()
			return

func _physics_process(delta: float) -> void:
	camera_pivot.global_transform = camera_pivot.global_transform.interpolate_with(
		camera_root.global_transform,delta*mech_move.camera_tracking_speed
	)
	camera.rotation.z = lerp(camera.rotation.z,deg_to_rad(-input.localdir.x) * velocity.length()/2,delta*3.0)
