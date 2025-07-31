extends Node
signal menu_displayed_changed(displayed: bool)

const MENU_OPENING_DELAY = 1.0
var n_menu_to_display: int = 0

func _ready() -> void:
    n_menu_to_display = 0
    %Timer.timeout.connect(func():
        if n_menu_to_display > 0:
            _show_lvl_up_menu(n_menu_to_display)
    )

func register_lvl_up():
    n_menu_to_display += 1
    if %Timer.is_stopped():
        %Timer.start(MENU_OPENING_DELAY)

func _show_lvl_up_menu(n_times: int):
    #print("Must show lvl_up menu %d times" % n_times)
    n_times -= 1
    var lvl_up_menu = preload("res://ui/menu/lvl_up/lvl_up_menu.tscn").instantiate()
    get_tree().root.add_child(lvl_up_menu)
    lvl_up_menu.picked_modifier.connect(func(mod: Modifiers.Mod):
        GameState.add_player_modifier(mod)
        lvl_up_menu.slide_out().finished.connect(func():
            lvl_up_menu.queue_free()
            if n_times <= 0:
                menu_displayed_changed.emit(false)
                GameState.change_state(GameState.State.RUNNING)
                n_menu_to_display = 0
            else:
                _show_lvl_up_menu(n_times)
        )
    )
    GameState.change_state(GameState.State.CHOOSING_UPGRADE)
    menu_displayed_changed.emit(true)
