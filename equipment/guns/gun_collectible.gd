extends CollectibleItem
class_name GunCollectible

@export var gun_name: String = "gun"

func _ready() -> void:
	%GunInfoPanel.init(GunService.get_info(gun_name))
	var joypads = Input.get_connected_joypads()
	if joypads.size() > 0:
		%ButtonIcon.key_name = "A"
		%ButtonIcon.controller_name = "xbox"
	else:
		%ButtonIcon.key_name = "E"
		%ButtonIcon.controller_name = "keyboard"
	%ButtonIcon.update_texture()

func _on_info_display_zone_body_entered(_body: Node2D) -> void:
	if %GunInfoPanel:
		%GunInfoPanel.show()
		%ButtonIcon.show()

func _on_info_display_zone_body_exited(_body: Node2D) -> void:
	if has_node("GunInfoPanel"):
		get_node("GunInfoPanel").hide()
	if has_node("ButtonIcon"):
		get_node("ButtonIcon").hide()
