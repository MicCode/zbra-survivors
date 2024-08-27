extends Resource
class_name GunInfo

var name = "gun"

var shots_per_s = 1.0
var fire_range = 2000.0

var bang_pitch_shift = 0.0

var bullet_damage: int = 10
var bullets_per_shot: int = 1
var bullets_spread_angle_deg: int = 0
var bullet_speed: int = 200
var bullets_speed_variability: float = 0.0

var eject_cartridges: bool = true
var inflict_fire: bool = false

func with_name(_name: String) -> GunInfo:
	name = _name
	return self

func with_bullets_per_shot(_bullets_per_shot: int) -> GunInfo:
	bullets_per_shot = _bullets_per_shot
	return self

func with_bullet_damage(_bullet_damage: int) -> GunInfo:
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

func with_shots_per_s(_shots_per_s: float) -> GunInfo:
	shots_per_s = _shots_per_s
	return self

func with_fire_range(_fire_range: float) -> GunInfo:
	fire_range = _fire_range
	return self

func with_bang_pitch_shift(_bang_pitch_shift: float) -> GunInfo:
	bang_pitch_shift = _bang_pitch_shift
	return self

func with_eject_cartridges(_eject_cartridges: bool) -> GunInfo:
	eject_cartridges = _eject_cartridges
	return self

func with_inflict_fire(_inflict_fire: bool) -> GunInfo:
	inflict_fire = _inflict_fire
	return self