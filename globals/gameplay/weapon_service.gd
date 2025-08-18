extends Node
signal equipped_weapon_changed(new_weapon: Weapon, previous_weapon_name: String)
signal weapon_stats_changed(new_stats: WeaponStats)
signal bullet_stats_changed(new_stats: BulletStats)

const EQUIPMENT_PATH = "res://items/"
const WEAPONS_PATH = "weapons/"

var all_weapon_names: Array[String] = []
var already_proposed_weapon_names: Array[String] = []
var equipped_weapon: Weapon
var base_equipped_weapon_stats: WeaponStats
var base_equipped_bullet_stats: BulletStats

var weapon_change_menu: WeaponChangeMenu

func _ready() -> void:
    var weapons_group: ResourceGroup = preload("res://items/weapons/weapons.tres")
    all_weapon_names = []
    for weapon_path in weapons_group.paths:
        all_weapon_names.append(weapon_path.split("/")[-1].split(".")[0])
    print("loaded weapons, founs [%d] weapons" % all_weapon_names.size())
    print(all_weapon_names)

func reset():
    change_equipped_weapon(null)

func create_weapon(_weapon_name: String) -> Weapon:
    var scene_path = _get_weapon_path(_weapon_name) + ".tscn"
    var scene = load(scene_path)
    if !scene:
        push_error("cannot find weapon scene [" + scene_path + "]")
        return null
    var instance = scene.instantiate() as Weapon
    instance.weapon_stats.resource_local_to_scene = true
    instance.bullet_stats.resource_local_to_scene = true
    return instance

func create_collectible(_weapon_name: String) -> ConsumableItem:
    var scene_path = _get_weapon_path(_weapon_name) + "_collectible.tscn"
    var scene = load(scene_path)
    if !scene:
        push_error("cannot find weapon collectible scene [" + scene_path + "]")
        return null
    var instance = scene.instantiate() as WeaponCollectible
    instance.weapon_stats.resource_local_to_scene = true
    instance.bullet_stats.resource_local_to_scene = true
    return instance

func create_projectile(_weapon_name: String) -> Bullet:
    var scene_path = _get_weapon_path(_weapon_name) + "_bullet.tscn"
    var scene = load(scene_path)
    if !scene:
        push_error("cannot find weapon projectile scene [" + scene_path + "]")
        return null
    var instance = scene.instantiate() as Bullet
    instance.bullet_stats.resource_local_to_scene = true
    return instance

func _get_weapon_path(_weapon_name: String) -> String:
    return EQUIPMENT_PATH + WEAPONS_PATH + _weapon_name + "/" + _weapon_name

func change_equipped_weapon(_new_weapon: Weapon, is_from_chest: bool = false) -> WeaponChangeMenu:
    if !_new_weapon:
        equipped_weapon = null
        base_equipped_weapon_stats = null
        base_equipped_bullet_stats = null
        return null

    var new_weapon_name = _new_weapon.get_weapon_name()

    if !equipped_weapon:
        # do not display the weapon swap menu the first time a weapon is picked up
        equipped_weapon = _new_weapon
        base_equipped_weapon_stats = _new_weapon.weapon_stats.duplicate(true)
        base_equipped_bullet_stats = _new_weapon.bullet_stats.duplicate(true)
        ModsService.compute_modifiers()
        equipped_weapon_changed.emit(equipped_weapon, "")
        return null

    if is_from_chest and !already_proposed_weapon_names.has(new_weapon_name):
        already_proposed_weapon_names.append(new_weapon_name)

    var new_weapon_base_equipped_weapon_stats = _new_weapon.weapon_stats.duplicate(true)
    _new_weapon.weapon_stats = WeaponStats.apply_modifiers(_new_weapon.weapon_stats, ModsService.active_mods)
    var new_weapon_base_equipped_bullet_stats = _new_weapon.bullet_stats.duplicate(true)
    _new_weapon.bullet_stats = BulletStats.apply_modifiers(_new_weapon.bullet_stats, ModsService.active_mods)
    weapon_change_menu = preload("res://ui/menu/weapon_change_menu.tscn").instantiate()
    weapon_change_menu.change_proposed_weapon(_new_weapon)
    SceneManager.current_scene.add_child(weapon_change_menu)
    GameService.change_state(E.GameState.PAUSED)

    weapon_change_menu.take_pressed.connect(func():
        var previous_weapon_name = equipped_weapon.get_weapon_name()
        equipped_weapon = _new_weapon
        if _new_weapon:
            base_equipped_weapon_stats = new_weapon_base_equipped_weapon_stats
            base_equipped_bullet_stats = new_weapon_base_equipped_bullet_stats
        else:
            base_equipped_weapon_stats = null
            base_equipped_bullet_stats = null
        ModsService.compute_modifiers()
        GameLogger.log_event(E.EventLogType.WEAPON_CHANGED, equipped_weapon.get_weapon_name())
        equipped_weapon_changed.emit(equipped_weapon, previous_weapon_name)
        weapon_change_menu.call_deferred("queue_free")
        GameService.change_state(E.GameState.RUNNING)
    )
    weapon_change_menu.keep_pressed.connect(func():
        weapon_change_menu.queue_free()
        drop_collectible(new_weapon_name, PlayerService.player_instance.global_position)
        GameService.change_state(E.GameState.RUNNING)
    )
    return weapon_change_menu

func drop_collectible(weapon_name: String, at_postion: Vector2):
    var collectible_to_drop = WeaponService.create_collectible(weapon_name)
    collectible_to_drop.global_position = at_postion
    SceneManager.current_scene.add_child(collectible_to_drop)
