extends Node

func get_gun_damage(gun: Gun) -> float:
    if gun is BasicGun:
        return 2.0
    elif gun is RifleGun:
        return 0.5
    else:
        return 1.0

func get_gun_cooldown(gun: Gun) -> float:
    if gun is BasicGun:
        return 1.0
    elif gun is RifleGun:
        return 0.25
    else:
        return 1.0

func get_gun_stats(gun: Gun) -> GunStats:
    return GunStats.create(get_gun_damage(gun), get_gun_cooldown(gun))