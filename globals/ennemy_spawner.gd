extends Node

func spawn() -> Ennemy:
    var rnd = randi_range(0, 1)
    match rnd:
        0: 
            return preload("res://entities/ennemies/Mob1/Mob1.tscn").instantiate()
        1: 
            return preload("res://entities/ennemies/Mob2/Mob2.tscn").instantiate()

    return null