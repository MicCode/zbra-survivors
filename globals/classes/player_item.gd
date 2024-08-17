class_name PlayerItem

var collectible: CollectibleItem
var equipment: EquipmentItem

func new(_collectible: CollectibleItem, _equipment: EquipmentItem) -> PlayerItem:
	collectible = _collectible
	equipment = _equipment
	return self
