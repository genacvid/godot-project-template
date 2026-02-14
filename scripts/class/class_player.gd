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
