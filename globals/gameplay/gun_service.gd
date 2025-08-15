extends Node
signal equipped_gun_changed(new_gun: Gun, previous_gun_name: String)
signal gun_stats_changed(new_stats: GunStats)
signal bullet_stats_changed(new_stats: BulletStats)

const EQUIPMENT_PATH = "res://items/"
const GUNS_PATH = "guns/"

var all_gun_names: Array[String] = []
var equipped_gun: Gun
var base_equipped_gun_stats: GunStats
var base_equipped_bullet_stats: BulletStats

var gun_change_menu: GunChangeMenu

func _ready() -> void:
    var guns_group: ResourceGroup = preload("res://items/guns/guns.tres")
    all_gun_names = []
    for gun_path in guns_group.paths:
        all_gun_names.append(gun_path.split("/")[-1].split(".")[0])
    print("loaded guns, founs [%d] guns" % all_gun_names.size())
    print(all_gun_names)

func reset():
    change_equipped_gun(null)

func create_gun(_gun_name: String) -> Gun:
    var scene_path = _get_gun_path(_gun_name) + ".tscn"
    var scene = load(scene_path)
    if !scene:
        push_error("cannot find gun scene [" + scene_path + "]")
        return null
    var instance = scene.instantiate() as Gun
    instance.gun_stats.resource_local_to_scene = true
    instance.bullet_stats.resource_local_to_scene = true
    return instance

func create_collectible(_gun_name: String) -> ConsumableItem:
    var scene_path = _get_gun_path(_gun_name) + "_collectible.tscn"
    var scene = load(scene_path)
    if !scene:
        push_error("cannot find gun collectible scene [" + scene_path + "]")
        return null
    var instance = scene.instantiate() as GunCollectible
    instance.gun_stats.resource_local_to_scene = true
    instance.bullet_stats.resource_local_to_scene = true
    return instance

func create_projectile(_gun_name: String) -> Bullet:
    var scene_path = _get_gun_path(_gun_name) + "_bullet.tscn"
    var scene = load(scene_path)
    if !scene:
        push_error("cannot find gun projectile scene [" + scene_path + "]")
        return null
    var instance = scene.instantiate() as Bullet
    instance.bullet_stats.resource_local_to_scene = true
    return instance

func _get_gun_path(_gun_name: String) -> String:
    return EQUIPMENT_PATH + GUNS_PATH + _gun_name + "/" + _gun_name

func change_equipped_gun(_new_gun: Gun) -> GunChangeMenu:
    if !_new_gun:
        equipped_gun = null
        base_equipped_gun_stats = null
        base_equipped_bullet_stats = null
        return null


    if !equipped_gun:
        # do not display the gun swap menu the first time a gun is picked up
        equipped_gun = _new_gun
        base_equipped_gun_stats = _new_gun.gun_stats.duplicate(true)
        base_equipped_bullet_stats = _new_gun.bullet_stats.duplicate(true)
        ModsService.compute_modifiers()
        equipped_gun_changed.emit(equipped_gun, "")
        return null

    var new_gun_base_equipped_gun_stats = _new_gun.gun_stats.duplicate(true)
    _new_gun.gun_stats = GunStats.apply_modifiers(_new_gun.gun_stats, ModsService.active_mods)
    var new_gun_base_equipped_bullet_stats = _new_gun.bullet_stats.duplicate(true)
    _new_gun.bullet_stats = BulletStats.apply_modifiers(_new_gun.bullet_stats, ModsService.active_mods)
    gun_change_menu = preload("res://ui/menu/gun_change_menu.tscn").instantiate()
    gun_change_menu.change_proposed_gun(_new_gun)
    SceneManager.current_scene.add_child(gun_change_menu)
    GameService.change_state(E.GameState.PAUSED)

    gun_change_menu.take_pressed.connect(func():
        var previous_gun_name = equipped_gun.get_gun_name()
        equipped_gun = _new_gun
        if _new_gun:
            base_equipped_gun_stats = new_gun_base_equipped_gun_stats
            base_equipped_bullet_stats = new_gun_base_equipped_bullet_stats
        else:
            base_equipped_gun_stats = null
            base_equipped_bullet_stats = null
        ModsService.compute_modifiers()
        equipped_gun_changed.emit(equipped_gun, previous_gun_name)
        gun_change_menu.call_deferred("queue_free")
        GameService.change_state(E.GameState.RUNNING)
    )
    gun_change_menu.keep_pressed.connect(func():
        gun_change_menu.queue_free()
        GameService.change_state(E.GameState.RUNNING)
    )
    return gun_change_menu
