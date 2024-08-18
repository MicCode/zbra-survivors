extends Node
const EQUIPMENT_PATH = "res://equipment/"
const GUNS_PATH = "guns/"

var guns_catalog = {
	"pistol": GunInfo.new()
		.with_name("pistol")
		.with_bullet_damage(2.0)
		.with_bullet_speed(1500)
		.with_shots_per_s(1)
		.with_bang_pitch_shift(-0.2),

	"rifle": GunInfo.new()
		.with_name("rifle")
		.with_bullet_damage(0.25)
		.with_bullet_speed(2000)
		.with_shots_per_s(5)
		.with_bullets_spread_angle_deg(15),

	"shotgun": GunInfo.new()
		.with_name("shotgun")
		.with_bullet_damage(0.5)
		.with_bullet_speed(1000)
		.with_shots_per_s(0.8)
		.with_bang_pitch_shift(-0.5)
		.with_bullets_per_shot(10)
		.with_bullets_spread_angle_deg(90)
		.with_bullets_speed_variability(0.25),
}

func get_gun_info(gun: Gun) -> GunInfo:
	return guns_catalog[_get_gun_name(gun)]

func to_equipment(collectible: CollectibleItem) -> EquipmentItem:
	if collectible is GunCollectible:
		var gun_name: String
		if collectible is PistolCollectible:
			gun_name = "pistol"
		elif collectible is RifleCollectible:
			gun_name = "rifle"
		elif collectible is ShotgunCollectible:
			gun_name = "shotgun"
		return load(_get_gun_path(gun_name) + ".tscn").instantiate()
	return null

func to_collectible(equipment: EquipmentItem) -> CollectibleItem:
	if equipment is Gun:
		return load(_get_gun_path(_get_gun_name(equipment)) + "_collectible.tscn").instantiate()
	return null

func get_gun_projectile(gun: Gun) -> GunProjectile:
	var projectile = load(_get_gun_path(_get_gun_name(gun)) + "_bullet.tscn").instantiate()
	if projectile:
		return projectile
	else:
		return load(EQUIPMENT_PATH + GUNS_PATH + "gun_projectile.tscn").instantiate()


func _get_gun_name(gun: Gun) -> String:
	if gun is Pistol:
		return "pistol"
	elif gun is Rifle:
		return "rifle"
	elif gun is Shotgun:
		return "shotgun"
	else:
		return "cannot find gun name"

func _get_gun_path(gun_name: String) -> String:
	return EQUIPMENT_PATH + GUNS_PATH + gun_name + "/" + gun_name
