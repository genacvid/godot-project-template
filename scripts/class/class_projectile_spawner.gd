extends MultiplayerSpawner
class_name ProjectileSpawner
@export var projectile_scene:PackedScene
func _init() -> void:
	spawn_function = _spawn_projectile
func _spawn_projectile(data) -> Projectile:
	var projectile:Projectile = projectile_scene.instantiate()
	projectile.direction = data["direction"]
	projectile.damage = data["damage"]
	projectile.speed = data["speed"]
	projectile.knockback = data["knockback"]
	projectile.spawn_origin = data["position"]
	projectile.attacker = data["attacker"]
	projectile.name = "Projectile" + str(multiplayer.get_unique_id())
	projectile.team = data["team"]
	return projectile
