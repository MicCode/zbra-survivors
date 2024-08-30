extends Node2D

var gun_info: GunInfo
var equipped_gun_info: GunInfo

func _ready() -> void:
	GameState.equipped_gun_changed.connect(_on_equipped_gun_changed)

func init(_gun_info: GunInfo):
	gun_info = _gun_info
	update_displayed_stats()
	

func _on_equipped_gun_changed(new_gun: Gun):
	equipped_gun_info = EquipmentService.get_gun_info(new_gun)
	update_displayed_stats()
	if equipped_gun_info && gun_info:
		%Attack.modulate = get_modulation_color(gun_info.bullet_damage, equipped_gun_info.bullet_damage)
		%DPS.modulate = get_modulation_color(get_dps(gun_info), get_dps(equipped_gun_info))
		%Reload.modulate = get_modulation_color(gun_info.shots_per_s, equipped_gun_info.shots_per_s)
		%BulletsCount.modulate = get_modulation_color(gun_info.bullets_per_shot, equipped_gun_info.bullets_per_shot)
		%Angle.modulate = get_modulation_color(gun_info.bullets_spread_angle_deg, equipped_gun_info.bullets_spread_angle_deg, true)
		
func update_displayed_stats():
	if gun_info:
		%Attack.text = str(gun_info.bullet_damage)
		%DPS.text = str(get_dps(gun_info))
		%Reload.text = str(gun_info.shots_per_s)
		%BulletsCount.text = str(gun_info.bullets_per_shot)
		%Angle.text = str(gun_info.bullets_spread_angle_deg) + "°"
		if equipped_gun_info:
			%Attack.text += get_diff(gun_info.bullet_damage, equipped_gun_info.bullet_damage)
			%DPS.text += get_diff(get_dps(gun_info), get_dps(equipped_gun_info))
			%Reload.text += get_diff(gun_info.shots_per_s, equipped_gun_info.shots_per_s)
			%BulletsCount.text += get_diff(gun_info.bullets_per_shot, equipped_gun_info.bullets_per_shot)
			%Angle.text += get_diff(gun_info.bullets_spread_angle_deg, equipped_gun_info.bullets_spread_angle_deg)

func get_modulation_color(a: float, b: float, invert = false) -> Color:
	if !invert && a > b || invert && a < b:
		return Color("#00ff00")
	elif !invert && a < b || invert && a > b:
		return Color("#d90000")
	else:
		return Color("#000000")

func get_diff(a: float, b: float) -> String:
	var diff = a - b
	if diff < 0:
		return " (" + str(diff) + ")" # already has the - sign
	elif diff > 0:
		return " (+" + str(diff) + ")"
	else:
		return ""

func get_dps(gun_info: GunInfo) -> float:
	return gun_info.bullet_damage * gun_info.bullets_per_shot * gun_info.shots_per_s
