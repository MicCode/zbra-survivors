extends Node

const BASIC_GUN_COLLECTIBLE = preload("res://entities/collectibles/weapons/BasicGunCollectible.tscn")
const BASIC_GUN_EQUIPMENT = preload("res://entities/equipments/guns/basic-gun/BasicGun.tscn")

func get_equipment(collectible: Collectible) -> EquipmentItem:
	if collectible.display_name == "basic_gun":
		return BASIC_GUN_EQUIPMENT.instantiate()
	else:
		return null
