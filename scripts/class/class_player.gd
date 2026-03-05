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
			input.camera_rotation.x = player_spawn.rotation.x
			model_root.rotation.x = player_spawn.rotation.x
			self.reset_physics_interpolation()
			input.rotate_camera()
			return

func _on_damage_component_killed(attacker: Entity) -> void:
	prints(name,"killed by",attacker.name)
	hud.update_health_bar(attacker)
	revive.rpc()
@rpc("call_local","any_peer")
func revive():
	global_position = Vector3.ZERO
	damage.health = 100.0
	damage.dead = false
