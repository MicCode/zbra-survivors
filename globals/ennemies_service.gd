extends Node
const ENNEMIES_PATH = "res://ennemies/"

var spawnable_ennemies = [
    "mob_1", "mob_2",
]

var all_ennemies = [
    "dummy",
] + spawnable_ennemies

func spawn_random() -> Ennemy:
    var random_ennemy = spawnable_ennemies[randi_range(0, spawnable_ennemies.size() - 1)]
    var scene_path = _get_ennemy_path(random_ennemy) + ".tscn"
    var scene = load(scene_path)
    if !scene:
        push_error("ennemy scene [" + scene_path + "] not found")
        return null
    var instance = scene.instantiate() as Ennemy
    instance.stats.resource_local_to_scene = true
    return instance

func _get_ennemy_path(ennemy_name: String) -> String:
    return ENNEMIES_PATH + ennemy_name + "/" + ennemy_name
