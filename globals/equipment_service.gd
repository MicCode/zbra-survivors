extends Node

func get_gun_damage(gun: Gun) -> float:
	if gun is BasicGun:
		return 2.0
	elif gun is RifleGun:
		return 0.5
	elif gun is ShotGun:
		return 0.5
	else:
		return 1.0

func get_gun_cooldown(gun: Gun) -> float:
	if gun is BasicGun:
		return 1.0
	elif gun is RifleGun:
		return 0.25
	elif gun is ShotGun:
		return 1.5
	else:
		return 1.0

func get_gun_projectile(gun: Gun) -> GunProjectile:
	if gun is BasicGun:
		return preload("res://equipments/guns/pistol/pistol_bullet.tscn").instantiate()
	elif gun is RifleGun:
		return preload("res://equipments/guns/rifle/rifle_bullet.tscn").instantiate()
	elif gun is ShotGun:
		return preload("res://equipments/guns/shotgun/shotgun_bullet.tscn").instantiate()
	else:
		return preload("res://equipments/guns/gun_projectile.tscn").instantiate()

func get_gun_bang_pitch_shift(gun: Gun) -> float:
	if gun is BasicGun:
		return -0.2
	elif gun is RifleGun:
		return 0.0
	elif gun is ShotGun:
		return -0.5
	else:
		return 0.0

func get_gun_stats(gun: Gun) -> GunStats:
	return GunStats.create(get_gun_damage(gun), get_gun_cooldown(gun))
