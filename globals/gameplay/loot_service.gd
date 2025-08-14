extends Node

var loot_chances: LootChances

func reset():
    loot_chances = preload("res://player/state/default_loot_chances.tres").duplicate()

func get_random_gun() -> Gun:
    var possible_guns: Array[String] = GunService.all_gun_names
    if GunService.equipped_gun != null:
        possible_guns = possible_guns.filter(func(gn: String): return gn != GunService.equipped_gun.get_gun_name())

    # TODO improve this random pick and make gun statistics random as well
    # TODO give different pick chance to each gun ?

    return GunService.create_gun(possible_guns[randi_range(0, possible_guns.size() - 1)])

func get_random_item() -> Node2D:
    # TODO implement a better random loot system
    if randf() <= LootService.loot_chances.life_drop_chance:
        return preload("res://items/consumables/life_flask/life_flask.tscn").instantiate().with_life_amount(1)
    if randf() <= LootService.loot_chances.radiance_drop_chance:
        return preload("res://items/consumables/radiance_flask/radiance_flask.tscn").instantiate()
    if randf() <= LootService.loot_chances.timewrap_drop_change:
        return preload("res://items/consumables/timewrap_clock/timewrap_clock.tscn").instantiate()
    if randf() <= LootService.loot_chances.xp_collector_drop_chance:
        return preload("res://items/consumables/xp_collector/xp_collector.tscn").instantiate()
    if randf() <= LootService.loot_chances.land_mine_chance:
        return preload("res://items/consumables/mine/mine_collectible.tscn").instantiate()

    return null
