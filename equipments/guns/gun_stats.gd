extends Object
class_name GunStats

var bullet_damage = 1.0
var fire_cooldown_s = 1.0
var fire_range = 200.0

static func create(damage: float, cooldown: float) -> GunStats:
	var instance = GunStats.new()
	instance.bullet_damage = damage
	instance.fire_cooldown_s = cooldown
	return instance
