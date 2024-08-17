extends Node

func to_equipment(collectible: Collectible) -> EquipmentItem:
	if collectible is GunCollectible:
		if collectible is BasicGunCollectible:
			return preload("res://equipments/guns/pistol/pistol.tscn").instantiate()
		elif collectible is RifleGunCollectible:
			return preload("res://equipments/guns/rifle/rifle.tscn").instantiate()
		elif collectible is ShotGunCollectible:
			return preload("res://equipments/guns/shotgun/shotgun.tscn").instantiate()
	return null

func to_collectible(equipment: EquipmentItem) -> Collectible:
	if equipment is Gun:
		if equipment is BasicGun:
			return preload("res://entities/collectibles/guns/BasicGun/BasicGunCollectible.tscn").instantiate()
		elif equipment is RifleGun:
			return preload("res://entities/collectibles/guns/Rifle/RifleGunCollectible.tscn").instantiate()
		elif equipment is ShotGun:
			return preload("res://entities/collectibles/guns/ShotGun/ShotGunCollectible.tscn").instantiate()
	return null
		
