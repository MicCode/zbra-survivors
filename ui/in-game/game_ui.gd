extends CanvasLayer

var player_health: int = 0
var player_max_health: int = 0
var player_xp: float = 0.0
var player_level: int = 0

const PIXELS_BETWEEN_HEARTS: int = 35
const HEARTS_START_X: int = 120
const HEARTS_START_Y: int = 619

func _ready() -> void:
    %Score.text = str(GameService.score)
    GameService.score_changed.connect(_on_score_changed)
    GameService.player_state_changed.connect(_on_player_state_changed)
    _on_player_state_changed(GameService.player_state)

func _on_score_changed(new_score: int):
    %Score.text = str(new_score)

func _on_player_state_changed(player_state: PlayerState):
    var changed = false
    if player_state.max_health != player_max_health:
        player_max_health = player_state.max_health
        changed = true

    if player_state.health != player_health:
        player_health = player_state.health
        changed = true

    if player_state.xp != player_xp:
        player_xp = player_state.xp
        %XpAnimationPlayer.play("xpgain")
        changed = true

    if player_state.level != player_level:
        player_level = player_state.level
        %XpAnimationPlayer.play("lvlup")
        changed = true

    if changed:
        var hearts = %Hearts.get_children()
        for heart in hearts:
            heart.queue_free()

        var x_position_offset = 0
        for i in range(0, player_max_health, 1):
            var new_heart = preload("res://ui/in-game/heart.tscn").instantiate()
            new_heart.position.x = HEARTS_START_X + x_position_offset
            new_heart.position.y = HEARTS_START_Y
            %Hearts.add_child(new_heart)
            if i > player_health - 1:
                new_heart.play("off")
            x_position_offset += PIXELS_BETWEEN_HEARTS

        %XpLabel.text = str(floor(player_xp)) + " / " + str(floor(player_state.next_level_xp))
        %LevelLabel.text = "Niv. " + str(player_state.level)

    %XpBar.max_value = player_state.next_level_xp
    %XpBar.value = player_state.xp

func set_remaining_time(remaining_s: float):
    var remaining_minutes = floor(remaining_s / 60 )
    var remaining_seconds = floor(remaining_s - remaining_minutes * 60)
    %RemainingTime.text = format_time(remaining_minutes, remaining_seconds)

func format_time(minutes: int, seconds: int) -> String:
    return str("%02d:%02d" % [minutes, seconds])
