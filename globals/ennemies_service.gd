extends Node
const ENNEMIES_PATH = "res://ennemies/"

var spawnable_ennemies = [
    EnnemyStats.new()
        .with_name("mob_1")
        .with_max_health(10)
        .with_speed(100.0)
        .with_xp_value(1.0),
    EnnemyStats.new()
        .with_name("mob_2")
        .with_max_health(25)
        .with_speed(150.0)
        .with_xp_value(1.5),
]

var all_ennemies = [
    EnnemyStats.new()
        .with_name("dummy")
        .with_can_die(false)
        .with_max_health(1_000_000_000),
] + spawnable_ennemies

func spawn_random() -> Ennemy:
    var random_ennemy = spawnable_ennemies[randi_range(0, spawnable_ennemies.size() - 1)]
    return load(_get_ennemy_path(random_ennemy.name) + ".tscn").instantiate() # FIXME test if scene exists before trying to instantiate

func get_stats(ennemy_name: String) -> EnnemyStats:
    var match = all_ennemies.filter(func(ennemy):
        return ennemy.name == ennemy_name
    )
    if match.size() > 0:
        return match[0]
    else:
        #TODO log error ?
        return null

func _get_ennemy_path(ennemy_name: String) -> String:
    return ENNEMIES_PATH + ennemy_name + "/" + ennemy_name
