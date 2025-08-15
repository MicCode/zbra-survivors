extends Node
signal active_mods_changed

const MODIFIER_CHANCE_DECREASE_PERCENT_PER_PICK: float = 20.0
const MODIFIERS_TEXTURES_FOLDER: String = "res://assets/sprites/modifiers"
const MODIFIERS_DEFINITIONS_FOLDER: String = "res://globals/gameplay/modifiers/definitions"
const DEBUG_MODE: bool = false

var all_mods: Dictionary[E.ModType, Array] = {}
var all_mods_flat: Array[ModifierDefinition] = []
var base_mod_values: Dictionary[E.ModName, float] = {
    # PLAYER
    E.ModName.PLAYER_MAX_HEALTH: 1,
    E.ModName.PLAYER_XP_COLLECT_RADIUS: 50.0,
    E.ModName.PLAYER_MOVE_SPEED: 10.0,
    E.ModName.PLAYER_DASH_DURATION: 20.0,
    E.ModName.PLAYER_DASH_COOLDOWN: - 20.0,
    E.ModName.PLAYER_DASH_SPEED_MULTIPLIER: 10.0,
    # GUN
    E.ModName.GUN_FIRE_RATE: 25.0,
    E.ModName.GUN_SPREAD_ANGLE_MORE: 30.0,
    E.ModName.GUN_SPREAD_ANGLE_LESS: - 30.0,
    E.ModName.GUN_BULLET_NUMBER: 2,
    # BULLET
    E.ModName.BULLET_DAMAGE: 10.0,
    E.ModName.BULLET_SPEED: 20.0,
    E.ModName.BULLET_RANGE: 20.0,
    E.ModName.BULLET_PIERCE_COUNT: 1,
    # EXPLOSION
    E.ModName.EXPLOSION_RADIUS: 25.0,
    E.ModName.EXPLOSION_DAMAGE: 10.0,
    # FIRE
    E.ModName.FIRE_DAMAGE: 10.0,
    E.ModName.FIRE_DURATION: 15.0,
    E.ModName.FIRE_FREQUENCY: 10.0,
}
var active_mods: Array[StatModifier] = []
var excluded_mods: Array[E.ModName] = []
var drop_chances: Dictionary[E.ModName, float] = {}

func _init():
    init_modifiers_dict()
    print("loaded all mods, found [%d] mods" % all_mods_flat.size())

func reset():
    active_mods.clear()
    excluded_mods.clear()
    active_mods_changed.emit()

func init_modifiers_dict():
    all_mods = {}
    for file in DirAccess.get_files_at(MODIFIERS_DEFINITIONS_FOLDER):
        if file.get_extension() == "tres":
            var definitions: ModifiersList = load(MODIFIERS_DEFINITIONS_FOLDER.path_join(file))
            all_mods.set(definitions.type, definitions.mods)
            all_mods_flat.append_array(definitions.mods)

func init_modifiers_chances():
    drop_chances = {}
    for mod in all_mods_flat:
        drop_chances.set(mod.name, 1.0) # TODO do not set all_mods modifiers with same probability ? make some increase with player level ?

func register_new_modifier(new_mod: ModifierDefinition):
    var new_stats_modifier = definition_to_stats_modifier(new_mod)
    var existing_modifiers: Array[StatModifier] = active_mods.filter(func(m: StatModifier): return m.name == new_stats_modifier.name)
    if existing_modifiers.is_empty():
        active_mods.append(new_stats_modifier)
    else:
        existing_modifiers[0].value += new_stats_modifier.value

    active_mods_changed.emit()
    decrease_chance(new_mod.name, MODIFIER_CHANCE_DECREASE_PERCENT_PER_PICK)
    compute_modifiers(new_stats_modifier)

## Transforms the Mod, which is a definition of a modifier, into a StatModifier, which is a real modifier ready to be applied on a statistic and has lighter information
func definition_to_stats_modifier(definition: ModifierDefinition) -> StatModifier:
    var base_value: float = base_mod_values.get(definition.name)
    if definition.is_absolute:
        return StatModifier.create_absolute(definition.name, base_value)
    else:
        return StatModifier.create_percent(definition.name, base_value)

func compute_modifiers(new_stats_modifier: StatModifier = null):
    var player_stats = PlayerService.player_stats
    var base_player_stats = PlayerService.base_player_stats

    var current_level = player_stats.level
    var current_xp = player_stats.xp
    var current_total_xp = player_stats.total_xp
    var current_next_level_xp = player_stats.next_level_xp
    var current_total_damage_dealt = player_stats.total_damage_dealt
    var current_total_damage_taken = player_stats.total_damage_taken

    player_stats = PlayerStats.apply_modifiers(base_player_stats, active_mods)

    player_stats.level = current_level
    player_stats.xp = current_xp
    player_stats.total_xp = current_total_xp
    player_stats.next_level_xp = current_next_level_xp
    player_stats.total_damage_dealt = current_total_damage_dealt
    player_stats.total_damage_taken = current_total_damage_taken

    if GunService.equipped_gun:
        GunService.equipped_gun.gun_stats = GunStats.apply_modifiers(GunService.base_equipped_gun_stats, active_mods)
        GunService.gun_stats_changed.emit(GunService.equipped_gun.gun_stats)
        GunService.equipped_gun.bullet_stats = BulletStats.apply_modifiers(GunService.base_equipped_bullet_stats, active_mods)
        GunService.bullet_stats_changed.emit(GunService.equipped_gun.bullet_stats)

    if new_stats_modifier and new_stats_modifier.name == E.ModName.PLAYER_MAX_HEALTH:
        player_stats.health += new_stats_modifier.value

    var explosions_modifiers: Array[StatModifier] = active_mods.filter(func(m: StatModifier): return m.is_type(E.ModType.EXPLOSION))
    if !explosions_modifiers.is_empty():
        PlayerService.explosions_damage = PlayerService.base_explosions_damage
        PlayerService.explosions_radius = PlayerService.base_explosions_radius
        for mod in explosions_modifiers:
            if mod.name == E.ModName.EXPLOSION_RADIUS:
                PlayerService.explosions_radius += mod.value
            elif mod.name == E.ModName.EXPLOSION_DAMAGE:
                PlayerService.explosions_damage += mod.value

    PlayerService.player_stats = player_stats
    PlayerService.emit_player_change()

func random_pick_n(n: int) -> Array[ModifierDefinition]:
    # TODO implement a more context aware picking system ? like better modifiers as the player level increases
    var picked_names: Array[E.ModName] = []
    for i in n:
        var pickable: Array[E.ModName] = []
        for mod in all_mods_flat:
            if excluded_mods.has(mod.name) or picked_names.has(mod.name):
                continue
            pickable.append(mod.name)

        if not pickable.is_empty():
            var filtered_drop_chances: Dictionary[E.ModName, float] = {}
            for mod_name in pickable:
                filtered_drop_chances.set(mod_name, drop_chances.get(mod_name))
            picked_names.append(Utils.weighted_pick(filtered_drop_chances) as E.ModName)

    return all_mods_flat.filter(func(m: ModifierDefinition): return picked_names.has(m.name))

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

func are_same_mods(mod1: ModifierDefinition, mod2: ModifierDefinition) -> bool:
    return mod1.name == mod2.name and mod1.type == mod2.type

func get_stat_name(mod_name: E.ModName) -> String:
    var found_mod: Array[ModifierDefinition] = all_mods_flat.filter(func(m: ModifierDefinition): return m.name == mod_name)
    if found_mod.is_empty():
        push_warning("Cannot get stat_name for unknown mod_name [%s]" % mod_name)
        return "???"
    return E.mod_stat_name(found_mod[0].name)

func get_type(mod_name: E.ModName) -> E.ModType:
    for mod_type in all_mods.keys():
        var mod_group: Array[ModifierDefinition] = all_mods.get(mod_type)
        for mod: ModifierDefinition in mod_group:
            if mod.name == mod_name:
                return mod_type
    push_error("ModType for mod [%s] not found in all_mods" % E.mod_name(mod_name))
    return E.ModType.UNKNOWN

func debug_print():
    print("= ModsService DEBUG ========================================================================")
    print("### all_mods ###")
    print(all_mods_flat.map(func(m: ModifierDefinition): return E.mod_name(m.name)))
    print("### actives ###")
    print(active_mods.map(func(m: StatModifier): return E.mod_name(m.name)))
    print("### excluded ###")
    print(excluded_mods.map(func(m: E.ModName): return E.mod_name(m)))
