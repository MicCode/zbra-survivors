extends Node
signal chest_registered(chest: LootChest)
signal chest_unregistered(chest: LootChest)

enum ItemName {
    LIFE_FLASK,
    RADIANCE_FLASK,
    TIMEWRAP_CLOCK,
    XP_COLLECTOR,
    MINE,
}

const CONSUMABLES_FOLDER = "res://items/consumables"
const CHANCE_TO_DROP_ITEM: float = 0.1 # TODO make this configurable / dynamic ? evolve with game progress ?
var loot_chances: LootChances
var item_chance_weights: Dictionary[ItemName, float] = {}

var chests: Array[LootChest] = []

func reset():
    loot_chances = preload("res://player/stats/default_loot_chances.tres").duplicate()
    chests = []
    item_chance_weights = {
        ItemName.LIFE_FLASK: loot_chances.life_drop_chance,
        ItemName.RADIANCE_FLASK: loot_chances.radiance_drop_chance,
        ItemName.TIMEWRAP_CLOCK: loot_chances.timewrap_drop_change,
        ItemName.XP_COLLECTOR: loot_chances.xp_collector_drop_chance,
        ItemName.MINE: loot_chances.land_mine_chance,
    }

func register_chest(chest: LootChest):
    chests.append(chest)
    GameLogger.log_event(E.EventLogType.CHEST_SPAWNED, str("%d,%d" % [chest.global_position.x, chest.global_position.y]))
    chest_registered.emit(chest)

func unregister_chest(chest: LootChest):
    if chests.has(chest):
        chests.erase(chest)
        chest_unregistered.emit(chest)

func get_random_gun() -> Gun:
    var possible_guns: Array[String] = GunService.all_gun_names
    if GunService.equipped_gun != null:
        possible_guns = possible_guns.filter(func(gn: String): return gn != GunService.equipped_gun.get_gun_name())
    if !GunService.already_proposed_gun_names.is_empty() and GunService.already_proposed_gun_names.size() < GunService.all_gun_names.size():
        possible_guns = possible_guns.filter(func(gn: String): return !GunService.already_proposed_gun_names.has(gn))

    # TODO improve this random pick and make gun statistics random as well
    # TODO give different pick chance to each gun ?

    return GunService.create_gun(possible_guns[randi_range(0, possible_guns.size() - 1)])

func get_random_item() -> Node2D:
    if randf() <= CHANCE_TO_DROP_ITEM:
        var picked_item_name: ItemName = Utils.weighted_pick(item_chance_weights) as ItemName
        var item_name_str = E.to_str(ItemName, picked_item_name).to_lower()
        var item = (load(CONSUMABLES_FOLDER.path_join(item_name_str).path_join(item_name_str) + ".tscn") as PackedScene).instantiate()
        if picked_item_name == ItemName.LIFE_FLASK:
            var life_amount: int = ceil(1 + PlayerService.player_stats.luck / 2)
            (item as LifeFlask).with_life_amount(life_amount)

        return item
    return null
