extends CanvasLayer

func _ready() -> void:
    %BossLife.hide()
    GameService.boss_changed.connect(_on_boss_changed)

func _on_boss_changed(boss_stats: EnnemyStats, boss_health: float):
    if boss_stats != null && boss_health > 0:
        %BossLife.show()
        %BossLife.max_value = boss_stats.max_health
        %BossLife.value = max(0, boss_health)
        %BossLifeLabel.text = str("%d / %d" % [max(0, boss_health), boss_stats.max_health])
        %BossNameLabel.text = boss_stats.nice_name
    else:
        %BossLife.hide()
