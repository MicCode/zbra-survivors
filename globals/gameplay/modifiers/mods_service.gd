extends Node
signal active_mods_changed

const MODIFIER_CHANCE_DECREASE_PERCENT_PER_PICK: float = 20.0
const MODIFIERS_TEXTURES_FOLDER: String = "res://assets/sprites/modifiers"
const DEBUG_MODE: bool = true

var all_mods: Array[Mod] = [
    # PLAYER MODS
    Mod.create(E.ModName.PLAYER_MAX_HEALTH, E.ModType.PLAYER, "max_health", "max-heath-up", 1, true),
    Mod.create(E.ModName.PLAYER_XP_COLLECT_RADIUS, E.ModType.PLAYER, "xp_collect_radius", "xp-collect-range-up", 50.0),
    Mod.create(E.ModName.PLAYER_MOVE_SPEED, E.ModType.PLAYER, "move_speed", "speed-up", 10.0),
    Mod.create(E.ModName.PLAYER_DASH_DURATION, E.ModType.PLAYER, "dash_duration", "dash-duration-up", 20.0),
    Mod.create(E.ModName.PLAYER_DASH_COOLDOWN, E.ModType.PLAYER, "dash_cooldown", "dash-cooldown-down", -20.0),
    Mod.create(E.ModName.PLAYER_DASH_SPEED_MULTIPLIER, E.ModType.PLAYER, "dash_speed_multiplier", "dash-speed-up", 10.0),

    # GUN MODS
    Mod.create(E.ModName.GUN_FIRE_RATE, E.ModType.GUN, "shots_per_s", "gun-fire-rate-up", 25.0),
    Mod.create(E.ModName.GUN_SPREAD_ANGLE_MORE, E.ModType.GUN, "bullets_spread_angle_deg", "bullet-spread-angle-up", 30.0),
    Mod.create(E.ModName.GUN_SPREAD_ANGLE_LESS, E.ModType.GUN, "bullets_spread_angle_deg", "bullet-spread-angle-down", -30.0),
    Mod.create(E.ModName.GUN_BULLET_NUMBER, E.ModType.GUN, "bullets_per_shot", "bullet-per-shot-up", 2, true),

    # BULLET MODS
    Mod.create(E.ModName.BULLET_DAMAGE, E.ModType.BULLET, "damage", "damage-up", 10.0),
    Mod.create(E.ModName.BULLET_SPEED, E.ModType.BULLET, "speed", "bullet-speed-up", 20.0),
    Mod.create(E.ModName.BULLET_RANGE, E.ModType.BULLET, "fly_range", "bullet-range-up", 20.0),
    Mod.create(E.ModName.BULLET_PIERCE_COUNT, E.ModType.BULLET, "pierce_count", "piercing-plus", 1, true),

    # EXPLOSION MODS
    Mod.create(E.ModName.EXPLOSION_RADIUS, E.ModType.EXPLOSION, "explosion_radius", "explosion-damage-radius-up", 25.0),
    Mod.create(E.ModName.EXPLOSION_DAMAGE, E.ModType.EXPLOSION, "explosion_damage", "explosion-damage-up", 10.0),

    Mod.create(E.ModName.FIRE_DAMAGE, E.ModType.FIRE, "fire_damage", "fire-damage-up", 10.0),
    Mod.create(E.ModName.FIRE_DURATION, E.ModType.FIRE, "fire_duration", "fire-duration-up", 15.0),
    Mod.create(E.ModName.FIRE_FREQUENCY, E.ModType.FIRE, "fire_tick_per_s", "fire-frequency-up", 10.0),
]
var active_mods: Array[StatsModifier] = []
var excluded_mods: Array[E.ModName] = []

var drop_chances: Dictionary[E.ModName, float] = {}

func reset():
    active_mods.clear()
    excluded_mods.clear()
    active_mods_changed.emit()


func init_modifiers_chances():
    drop_chances = {}
    for mod in ModsService.all_mods:
        drop_chances.set(mod.name, 1.0) # TODO do not set all_mods modifiers with same probability ? make some increase with player level ?

func register_new_modifier(new_mod: Mod):
    var new_stats_modifier = new_mod.to_stats_modifier()
    var existing_modifiers: Array[StatsModifier] = active_mods.filter(func(m: StatsModifier): return m.modifier == new_stats_modifier.modifier)
    if existing_modifiers.is_empty():
        active_mods.append(new_stats_modifier)
    else:
        existing_modifiers[0].modifier_value += new_stats_modifier.modifier_value

    active_mods_changed.emit()
    decrease_chance(new_mod.name, MODIFIER_CHANCE_DECREASE_PERCENT_PER_PICK)
    compute_modifiers(new_stats_modifier)

func compute_modifiers(new_stats_modifier: StatsModifier = null):
    var player_state = PlayerService.player_state
    var base_player_state = PlayerService.base_player_state

    var current_level = player_state.level
    var current_xp = player_state.xp
    var current_total_xp = player_state.total_xp
    var current_next_level_xp = player_state.next_level_xp
    var current_total_damage_dealt = player_state.total_damage_dealt
    var current_total_damage_taken = player_state.total_damage_taken

    player_state = PlayerState.apply_modifiers(base_player_state, active_mods)

    player_state.level = current_level
    player_state.xp = current_xp
    player_state.total_xp = current_total_xp
    player_state.next_level_xp = current_next_level_xp
    player_state.total_damage_dealt = current_total_damage_dealt
    player_state.total_damage_taken = current_total_damage_taken

    if GunService.equipped_gun:
        GunService.equipped_gun.gun_stats = GunStats.apply_modifiers(GunService.base_equipped_gun_stats, active_mods)
        GunService.gun_stats_changed.emit(GunService.equipped_gun.gun_stats)
        GunService.equipped_gun.bullet_stats = BulletStats.apply_modifiers(GunService.base_equipped_bullet_stats, active_mods)
        GunService.bullet_stats_changed.emit(GunService.equipped_gun.bullet_stats)

    if new_stats_modifier and new_stats_modifier.modifier == E.ModName.PLAYER_MAX_HEALTH:
        player_state.health += new_stats_modifier.modifier_value

    var explosions_modifiers: Array[StatsModifier] = active_mods.filter(func(m: StatsModifier): return m.is_type(E.ModType.EXPLOSION))
    if !explosions_modifiers.is_empty():
        PlayerService.explosions_damage = PlayerService.base_explosions_damage
        PlayerService.explosions_radius = PlayerService.base_explosions_radius
        for mod in explosions_modifiers:
            if mod.modifier == E.ModName.EXPLOSION_RADIUS:
                PlayerService.explosions_radius += mod.modifier_value
            elif mod.modifier == E.ModName.EXPLOSION_DAMAGE:
                PlayerService.explosions_damage += mod.modifier_value

    PlayerService.emit_player_change()

func random_pick_n(n: int) -> Array[Mod]:
    # TODO implement a more context aware picking system ? like better modifiers as the player level increases
    var picked_names: Array[E.ModName] = []
    for i in n:
        var pickable: Array[E.ModName] = []
        for mod in all_mods:
            if excluded_mods.has(mod.name) or picked_names.has(mod.name):
                continue
            pickable.append(mod.name)

        if not pickable.is_empty():
            var filtered_drop_chances: Dictionary[E.ModName, float] = {}
            for mod_name in pickable:
                filtered_drop_chances.set(mod_name, drop_chances.get(mod_name))
            picked_names.append(Utils.weighted_pick(filtered_drop_chances) as E.ModName)

    var picked_mods = all_mods.filter(func(m: Mod): return picked_names.has(m.name))
    return picked_mods

## Decrease in percent applied to a modifier so it has less chance to be randomly picked at next level up
func decrease_chance(mod_name: E.ModName, decrease_percent: float):
    if drop_chances.has(mod_name):
        var current_chance: float = drop_chances.get(mod_name)
        drop_chances.set(mod_name, Utils.sub_percent(current_chance, decrease_percent))
        if DEBUG_MODE: print_modifiers_chances()

func print_modifiers_chances():
    print("#### STATS MODIFIERS DROP CHANCES ####")
    for key in drop_chances.keys():
        print("  - %s: %.2f" % [E.mod_name(key), drop_chances.get(key)])
    print("######################################")

func are_same_mods(mod1: Mod, mod2: Mod) -> bool:
    return mod1.name == mod2.name and mod1.type == mod2.type

func get_stat_name(mod_name: E.ModName) -> String:
    var found_mod: Array[Mod] = all_mods.filter(func(m: Mod): return m.name == mod_name)
    if found_mod.is_empty():
        push_warning("Cannot get stat_name for unknown mod_name [%s]" % mod_name)
        return "???"
    return found_mod[0].stat_name

func get_type(mod_name: E.ModName) -> E.ModType:
    var found_mod: Array[Mod] = all_mods.filter(func(m: Mod): return m.name == mod_name)
    if found_mod.is_empty():
        push_warning("Cannot get type for unknown mod_name [%s]" % mod_name)
        return E.ModType.UNKNOWN
    return found_mod[0].type
