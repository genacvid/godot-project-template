extends MultiplayerSpawner
class_name ProjectileSpawner
var projectile_scene:PackedScene
func _init() -> void:
	spawn_function = _spawn_projectile
func _spawn_projectile(data) -> Projectile:
	var projectile:Projectile = projectile_scene.instantiate()
	projectile.global_position = data["pos"]
	projectile.direction = data["direction"]
	projectile.attacker = data["attacker"]
	return projectile
