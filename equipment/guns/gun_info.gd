extends Resource
class_name GunInfo

var name = "gun"

var fire_cooldown_s = 1.0
var fire_range = 200.0

var bang_pitch_shift = 0.0

var bullet_damage: float = 1.0
var bullets_per_shot: int = 1
var bullets_spread_angle_deg: int = 0
var bullet_speed: int = 200
var bullets_speed_variability: float = 0.0

func with_name(_name: String) -> GunInfo:
	name = _name
	return self

func with_bullets_per_shot(_bullets_per_shot: int) -> GunInfo:
	bullets_per_shot = _bullets_per_shot
	return self

func with_bullet_damage(_bullet_damage: float) -> GunInfo:
	bullet_damage = _bullet_damage
	return self

func with_bullets_spread_angle_deg(_bullets_spread_angle_deg: int) -> GunInfo:
	bullets_spread_angle_deg = _bullets_spread_angle_deg
	return self

func with_bullets_speed_variability(_bullets_speed_variability: float) -> GunInfo:
	bullets_speed_variability = _bullets_speed_variability
	return self

func with_bullet_speed(_bullet_speed: int) -> GunInfo:
	bullet_speed = _bullet_speed
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