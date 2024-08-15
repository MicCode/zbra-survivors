extends Node

func spawn() -> Ennemy:
	var rnd = randi_range(0, 1)
	match rnd:
		0: 
			return preload("res://entities/ennemies/Mob1/Mob1.tscn").instantiate()
		1: 
			return preload("res://entities/ennemies/Mob2/Mob2.tscn").instantiate()

	return null

func get_ennemy_stats(ennemy: Ennemy) -> EnnemyStats:
	if ennemy is Mob1:
		return EnnemyStats.create(3.0, 200.0)
	elif ennemy is Mob2:
		return EnnemyStats.create(4.0, 175.0)
	else:
		return EnnemyStats.create(1.0, 200.0)