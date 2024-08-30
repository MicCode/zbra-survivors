extends CollectibleItem
class_name GunCollectible

func _ready() -> void:
	var gun = EquipmentService.to_equipment(self)
	if gun != null:
		%GunInfoPanel.init(EquipmentService.get_gun_info(gun))


func _on_info_display_zone_body_entered(body: Node2D) -> void:
	if %GunInfoPanel:
		%GunInfoPanel.show()

func _on_info_display_zone_body_exited(body: Node2D) -> void:
	if %GunInfoPanel:
		%GunInfoPanel.hide()
