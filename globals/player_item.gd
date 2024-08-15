extends Node
class_name PlayerItem

var collectible: Collectible
var equipment: EquipmentItem

func new(_collectible: Collectible, _equipment: EquipmentItem) -> PlayerItem:
	collectible = _collectible
	equipment = _equipment
	return self
