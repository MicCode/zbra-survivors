extends CanvasLayer
class_name GunChangeMenu

signal take_pressed
signal keep_pressed

const ANIMATION_TIME: float = 0.1

var gun: Gun

func _ready() -> void:
    Sounds.button_press()
    slide_in().finished.connect(func():
        %TakeButton.grab_focus()
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

func change_proposed_gun(new_gun: Gun):
    gun = new_gun
    %NewGun.change_gun(gun, "")
    %NewGun.change_compare_to(GunService.equipped_gun)
    %EquippedGun.change_compare_to(gun)

func _on_keep_button_pressed() -> void:
    Sounds.button_press()
    slide_out().finished.connect(func():
        keep_pressed.emit()
    )

func _on_take_button_pressed() -> void:
    Sounds.button_press()
    slide_out().finished.connect(func():
        take_pressed.emit()
    )
