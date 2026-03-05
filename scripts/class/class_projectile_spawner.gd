extends MultiplayerSpawner
class_name ProjectileSpawner
const PROJECTILE_BASE = preload("uid://bdwr1uqv4841g")

func _init() -> void:
	spawn_function = _spawn_projectile

func _spawn_projectile(data) -> Projectile:
	var projectile:Projectile = PROJECTILE_BASE.instantiate()
	projectile.direction = data["direction"]
	projectile.spawn_origin = data["position"]
	projectile.attacker = data["attacker"]
	projectile.name = "Projectile" + str(multiplayer.get_unique_id())
	return projectile
