extends CollectibleItem
class_name GunCollectible

@export var gun_name: String = "gun"

func _ready() -> void:
	%GunInfoPanel.init(GunService.get_info(gun_name))


func _on_info_display_zone_body_entered(_body: Node2D) -> void:
	if %GunInfoPanel:
		%GunInfoPanel.show()

func _on_info_display_zone_body_exited(_body: Node2D) -> void:
	if has_node("GunInfoPanel"):
		get_node("GunInfoPanel").hide()
