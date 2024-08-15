extends Node

const BASIC_GUN_COLLECTIBLE = preload("res://entities/collectibles/guns/BasicGun/BasicGunCollectible.tscn")
const BASIC_GUN_EQUIPMENT = preload("res://entities/equipments/guns/basic-gun/BasicGun.tscn")

const RIFLE_GUN_COLLECTIBLE = preload("res://entities/collectibles/guns/Rifle/RifleGunCollectible.tscn")
const RIFLE_GUN_EQUIPMENT = preload("res://entities/equipments/guns/rifle-gun/RifleGun.tscn")

func to_equipment(collectible: Collectible) -> EquipmentItem:
	if collectible is GunCollectible:
		if collectible is BasicGunCollectible:
			return BASIC_GUN_EQUIPMENT.instantiate()
		elif collectible is RifleGunCollectible:
			return RIFLE_GUN_EQUIPMENT.instantiate()
	
	return null

func to_collectible(equipment: EquipmentItem) -> Collectible:
	if equipment is Gun:
		if equipment is BasicGun:
			return BASIC_GUN_COLLECTIBLE.instantiate()
		elif equipment is RifleGun:
			return RIFLE_GUN_COLLECTIBLE.instantiate()

	return null
		
