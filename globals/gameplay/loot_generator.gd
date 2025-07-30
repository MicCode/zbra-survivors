extends Node

var all_known_gun_names: Array[String] = [
    "flamethrower",
    "pistol",
    "rifle",
    "shotgun",
    "sniper"
]

func get_random_gun() -> Gun:
    var possible_gun_names = all_known_gun_names
    if GameState.equipped_gun != null:
        possible_gun_names = all_known_gun_names.filter(func(gn: String): return gn != GameState.equipped_gun.gun_stats.name)

    # TODO improve this random pick and make gun statistics random as well
    # TODO give different pick chance to each gun ?

    return GunService.create_gun(possible_gun_names[randi_range(0, possible_gun_names.size() - 1)])
