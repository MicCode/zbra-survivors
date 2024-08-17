extends Resource
class_name GunInfo

var name = "gun"
var bullet_damage = 1.0
var fire_cooldown_s = 1.0
var fire_range = 200.0
var bang_pitch_shift = 0.0

func with_name(_name: String) -> GunInfo:
	name = _name
	return self

func with_bullet_damage(_bullet_damage: float) -> GunInfo:
	bullet_damage = _bullet_damage
	return self

func with_fire_cooldown_s(_fire_cooldown_s: float) -> GunInfo:
	fire_cooldown_s = _fire_cooldown_s
	return self

func with_fire_range(_fire_range: float) -> GunInfo:
	fire_range = _fire_range
	return self

func with_bang_pitch_shift(_bang_pitch_shift: float) -> GunInfo:
	bang_pitch_shift = _bang_pitch_shift
	return self