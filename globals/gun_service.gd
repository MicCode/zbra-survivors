extends Node
const EQUIPMENT_PATH = "res://equipment/"
const GUNS_PATH = "guns/"

var guns_catalog = [
    GunInfo.new()
        .with_name("pistol")
        .with_display_name("Pistol")
        .with_bang_pitch_shift(-0.2)
        .with_bullet_damage(10)
        .with_bullet_speed(1000)
        .with_shots_per_s(1),
    GunInfo.new()
        .with_name("rifle")
        .with_display_name("Assault Rifle")
        .with_bullet_damage(3)
        .with_bullet_speed(1750)
        .with_bullets_spread_angle_deg(15)
        .with_shots_per_s(10),
    GunInfo.new()
        .with_name("shotgun")
        .with_display_name("Shotgun")
        .with_bang_pitch_shift(-0.5)
        .with_bullet_damage(3)
        .with_bullet_speed(750)
        .with_bullets_per_shot(10)
        .with_bullets_speed_delta(0.25)
        .with_bullets_spread_angle_deg(90)
        .with_shots_per_s(0.8),
    GunInfo.new()
        .with_name("flamethrower")
        .with_display_name("Flame Thrower")
        .with_bang_pitch_shift(-0.8)
        .with_bang_volume(-12.0)
        .with_bullet_damage(1)
        .with_bullet_speed(500)
        .with_bullets_per_shot(1)
        .with_bullets_speed_delta(0.5)
        .with_bullets_spread_angle_deg(50)
        .with_bullet_size(2.0)
        .with_bullet_size_delta(0.25)
        .with_eject_cartridges(false)
        .with_fire_range(100)
        .with_inflict_fire(true)
        .with_shots_per_s(50),
    GunInfo.new()
        .with_name("sniper")
        .with_display_name("Sniper Rifle")
        .with_bullet_speed(2000)
        .with_bullet_damage(25)
        .with_fire_range(750)
        .with_shots_per_s(0.5)
        .with_bang_pitch_shift(-0.3)
        .with_pierce_count(3),
]

func get_info(gun_name: String) -> GunInfo:
    var match = guns_catalog.filter(func(gun):
        return gun.name == gun_name
    )
    if match.size() > 0:
        return match[0]
    else:
        #TODO log error ?
        return null

func create_gun(gun_name: String) -> Gun:
    return load(_get_gun_path(gun_name) + ".tscn").instantiate() # FIXME test if scene exists before trying to instantiate

func create_collectible(gun_name: String) -> CollectibleItem:
    return load(_get_gun_path(gun_name) + "_collectible.tscn").instantiate() # FIXME test if scene exists before trying to instantiate

func create_projectile(gun_name: String) -> Bullet:
    var projectile = load(_get_gun_path(gun_name) + "_bullet.tscn") # FIXME test if scene exists before trying to instantiate
    if projectile:
        return projectile.instantiate() # FIXME test if scene exists before trying to instantiate
    else:
        return load(EQUIPMENT_PATH + GUNS_PATH + "gun_projectile.tscn").instantiate()

func _get_gun_path(gun_name: String) -> String:
    return EQUIPMENT_PATH + GUNS_PATH + gun_name + "/" + gun_name
