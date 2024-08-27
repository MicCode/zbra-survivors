extends Node
const ENNEMIES_PATH = "res://ennemies/"

const MOB_1 = "mob_1"
const MOB_2 = "mob_2"

var ennemies_catalog = {
	MOB_1: EnnemyInfo.new()
		.with_name(MOB_1)
		.with_max_health(30)
		.with_speed(200.0)
		.with_xp_value(1.0),

	MOB_2: EnnemyInfo.new()
		.with_name(MOB_2)
		.with_max_health(40)
		.with_speed(175.0)
		.with_xp_value(1.5),
}

func spawn_random() -> Ennemy:
	var ennemy_name = ennemies_catalog.keys()[randi_range(0, ennemies_catalog.size() - 1)]
	return load(_get_ennemy_path(ennemy_name) + ".tscn").instantiate()

func get_info(ennemy: Ennemy) -> EnnemyInfo:
	return ennemies_catalog[_get_ennemy_name(ennemy)]

func _get_ennemy_name(ennemy: Ennemy) -> String:
	if ennemy is Mob1:
		return MOB_1
	elif ennemy is Mob2:
		return MOB_2
	else:
		return "cannot find ennemy name"

func _get_ennemy_path(ennemy_name: String) -> String:
	return ENNEMIES_PATH + ennemy_name + "/" + ennemy_name
