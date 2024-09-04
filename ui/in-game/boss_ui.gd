extends CanvasLayer

var boss_info: EnnemyInfo

func _ready() -> void:
	%BossLife.hide()
	GameService.boss_changed.connect(_on_boss_changed)
	
func _on_boss_changed(boss_info: EnnemyInfo):
	if boss_info != null:
		%BossLife.show()
		%BossLife.max_value = boss_info.max_health
		%BossLife.value = max(0, boss_info.health)
		%BossLifeLabel.text = str("%d / %d" % [max(0, boss_info.health), boss_info.max_health])
		%BossNameLabel.text = boss_info.nice_name
	else:
		%BossLife.hide()
