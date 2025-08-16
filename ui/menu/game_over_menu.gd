extends CanvasLayer

const ANIMATION_TIME: float = 0.1
const SHOW_TIME: float = 10.0

var can_be_cancelled = false
var is_success = false

func _ready() -> void:
    if is_success:
        MusicManager.set_non_layered_music("zbra-slain.ogg")
        %Label.add_theme_color_override("font_color", Color("c39200"))
        %Label.text = tr("TITLE_GAME_SUCCESS")
    else:
        MusicManager.set_non_layered_music("game-over.ogg")
        Sounds.game_over()
        %Label.add_theme_color_override("font_color", Color("c30700"))
        %Label.text = tr("TITLE_GAME_OVER")

    slide_in().finished.connect(func():
        can_be_cancelled = true
        get_tree().create_timer(SHOW_TIME).timeout.connect(func():
            leave()
        )
    )

func _process(_delta: float) -> void:
    if can_be_cancelled and Input.is_anything_pressed():
        leave()

func leave():
    slide_out().finished.connect(func():
        GameService.change_state(E.GameState.NOT_STARTED)
        SceneManager.switch_to("res://ui/menu/game_logs/game_logs_menu.tscn")
        queue_free()
    )

func slide_in() -> PropertyTweener:
    %MainContainer.position = Vector2(0.0, %MainContainer.size.y)
    %MainContainer.scale = Vector2(1.0, 0.0)
    create_tween().tween_property(%MainContainer, "scale", Vector2(1.0, 1.0), ANIMATION_TIME)
    return create_tween().tween_property(%MainContainer, "position", Vector2(0.0, 0.0), ANIMATION_TIME)

func slide_out() -> PropertyTweener:
    %MainContainer.position = Vector2(0.0, 0.0)
    %MainContainer.scale = Vector2(1.0, 1.0)
    create_tween().tween_property(%MainContainer, "scale", Vector2(1.0, 0.0), ANIMATION_TIME)
    return create_tween().tween_property(%MainContainer, "position", Vector2(0.0, %MainContainer.size.y), ANIMATION_TIME)
