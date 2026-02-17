extends Entity
class_name Player
@onready var camera: Camera3D = $CameraPivot/Camera
@onready var hud: HUD = $HUD
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
			self.reset_physics_interpolation()
