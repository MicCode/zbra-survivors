extends Control

var fade_in_time: float = 0.5
var fade_out_time: float = 1.0
var splash_duration: float = 5.0
var skip_splash: bool = !OS.is_debug_build()

func _ready() -> void:
    SoundPlayer.apply_audio_settings()
    if skip_splash:
        SceneManager.switch_to("res://ui/menu/main_menu.tscn")

    SoundPlayer.play_music("main-menu.mp3")
    %VBoxContainer.modulate = Color.TRANSPARENT
    create_tween().tween_property(%VBoxContainer, "modulate", Color.WHITE, fade_in_time)
    get_tree().create_timer(splash_duration - fade_out_time).connect("timeout", leave_splash)
    %StudioName.visible_ratio = 0.0
    create_tween().tween_property(%StudioName, "visible_ratio", 1.0, fade_in_time * 2)

func _input(event: InputEvent) -> void:
    if event.is_pressed():
        leave_splash()

func leave_splash():
    create_tween().tween_property(%VBoxContainer, "modulate", Color.TRANSPARENT, fade_out_time).connect("finished", func():
        SceneManager.switch_to("res://ui/menu/main_menu.tscn")
    )
