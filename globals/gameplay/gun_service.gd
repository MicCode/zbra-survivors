extends Node
const EQUIPMENT_PATH = "res://items/"
const GUNS_PATH = "guns/"

enum HapticFeedback {
    ONE_SHOT,
    ONE_SHOT_HEAVY,
    AUTOMATIC,
    CONTINUOUS,
}

func create_gun(gun_name: String) -> Gun:
    var scene_path = _get_gun_path(gun_name) + ".tscn"
    var scene = load(scene_path)
    if !scene:
        push_error("cannot find gun scene [" + scene_path + "]")
        return null
    var instance = scene.instantiate() as Gun
    instance.gun_stats.resource_local_to_scene = true
    instance.bullet_stats.resource_local_to_scene = true
    return instance

func create_collectible(gun_name: String) -> ConsumableItem:
    var scene_path = _get_gun_path(gun_name) + "_collectible.tscn"
    var scene = load(scene_path)
    if !scene:
        push_error("cannot find gun collectible scene [" + scene_path + "]")
        return null
    var instance = scene.instantiate() as GunCollectible
    instance.gun_stats.resource_local_to_scene = true
    instance.bullet_stats.resource_local_to_scene = true
    return instance

func create_projectile(gun_name: String) -> Bullet:
    var scene_path = _get_gun_path(gun_name) + "_bullet.tscn"
    var scene = load(scene_path)
    if !scene:
        push_error("cannot find gun projectile scene [" + scene_path + "]")
        return null
    var instance = scene.instantiate() as Bullet
    instance.bullet_stats.resource_local_to_scene = true
    return instance

func _get_gun_path(gun_name: String) -> String:
    return EQUIPMENT_PATH + GUNS_PATH + gun_name + "/" + gun_name
