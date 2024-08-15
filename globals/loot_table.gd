extends Node

func to_equipment(collectible: Collectible) -> EquipmentItem:
	if collectible is GunCollectible:
		if collectible is BasicGunCollectible:
			return preload("res://entities/equipments/guns/BasicGun/BasicGun.tscn").instantiate()
		elif collectible is RifleGunCollectible:
			return preload("res://entities/equipments/guns/RifleGun/RifleGun.tscn").instantiate()
	return null

func to_collectible(equipment: EquipmentItem) -> Collectible:
	if equipment is Gun:
		if equipment is BasicGun:
			return preload("res://entities/collectibles/guns/BasicGun/BasicGunCollectible.tscn").instantiate()
		elif equipment is RifleGun:
			return preload("res://entities/collectibles/guns/Rifle/RifleGunCollectible.tscn").instantiate()
	return null
		
