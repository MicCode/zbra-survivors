extends Node
const EQUIPMENT_PATH = "res://equipment/"
const GUNS_PATH = "guns/"

const PISTOL = "pistol"
const RIFLE = "rifle"
const SHOTGUN = "shotgun"
const FLAMETHROWER = "flamethrower"
const SNIPER = "sniper"

var guns_catalog = {
	PISTOL: GunInfo.new()
		.with_name(PISTOL)
		.with_display_name("Pistol")
		.with_bang_pitch_shift(-0.2)
		.with_bullet_damage(20)
		.with_bullet_speed(1500)
		.with_shots_per_s(1),

	RIFLE: GunInfo.new()
		.with_name(RIFLE)
		.with_display_name("Assault Rifle")
		.with_bullet_damage(3)
		.with_bullet_speed(2000)
		.with_bullets_spread_angle_deg(15)
		.with_shots_per_s(10),

	SHOTGUN: GunInfo.new()
		.with_name(SHOTGUN)
		.with_display_name("Shotgun")
		.with_bang_pitch_shift(-0.5)
		.with_bullet_damage(5)
		.with_bullet_speed(1000)
		.with_bullets_per_shot(10)
		.with_bullets_speed_variability(0.25)
		.with_bullets_spread_angle_deg(90)
		.with_shots_per_s(0.8),

	FLAMETHROWER: GunInfo.new()
		.with_name(FLAMETHROWER)
		.with_display_name("Flame Thrower")
		.with_bang_pitch_shift(-0.8)
		.with_bullet_damage(1)
		.with_bullet_speed(750)
		.with_bullets_per_shot(1)
		.with_bullets_speed_variability(0.5)
		.with_bullets_spread_angle_deg(50)
		.with_eject_cartridges(false)
		.with_fire_range(200)
		.with_inflict_fire(true)
		.with_shots_per_s(50),

	SNIPER: GunInfo.new()
		.with_name(SNIPER)
		.with_display_name("Sniper Rifle")
		.with_bullet_speed(3000)
		.with_bullet_damage(100)
		.with_fire_range(1000)
		.with_shots_per_s(0.5)
		.with_bang_pitch_shift(-0.3)
		.with_pierce_count(3),
}

func get_gun_info(gun: Gun) -> GunInfo:
	return guns_catalog[_get_gun_name(gun)]

func to_equipment(collectible: CollectibleItem) -> EquipmentItem:
	if collectible is GunCollectible:
		var gun_name: String
		if collectible is PistolCollectible:
			gun_name = PISTOL
		elif collectible is RifleCollectible:
			gun_name = RIFLE
		elif collectible is ShotgunCollectible:
			gun_name = SHOTGUN
		elif collectible is FlamethrowerCollectible:
			gun_name = FLAMETHROWER
		elif collectible is SniperCollectible:
			gun_name = SNIPER
		return load(_get_gun_path(gun_name) + ".tscn").instantiate()
	return null

func to_collectible(equipment: EquipmentItem) -> CollectibleItem:
	if equipment is Gun:
		return load(_get_gun_path(_get_gun_name(equipment)) + "_collectible.tscn").instantiate()
	return null

func get_gun_projectile(gun: Gun) -> Bullet:
	var projectile = load(_get_gun_path(_get_gun_name(gun)) + "_bullet.tscn")
	if projectile:
		return projectile.instantiate()
	else:
		return load(EQUIPMENT_PATH + GUNS_PATH + "gun_projectile.tscn").instantiate()


func _get_gun_name(gun: Gun) -> String:
	if gun is Pistol:
		return PISTOL
	elif gun is Rifle:
		return RIFLE
	elif gun is Shotgun:
		return SHOTGUN
	elif gun is Flamethrower:
		return FLAMETHROWER
	elif gun is Sniper:
		return SNIPER
	else:
		return "cannot find gun name"

func _get_gun_path(gun_name: String) -> String:
	return EQUIPMENT_PATH + GUNS_PATH + gun_name + "/" + gun_name
