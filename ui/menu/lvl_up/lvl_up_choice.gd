extends Control
class_name LvlUpChoice

signal clicked
signal excluded_changed(excluded: bool)

const HOVER_ANIMATION_DURATION = 0.1
var panel_style: StyleBoxFlat
var has_been_clicked = false
var block_focus = false
var mod_definition: ModifierDefinition:
    set(new_definition):
        mod_definition = new_definition
        refresh_display()
var is_hovered = false
var prevent_mouse_click = false
var excluded = false
var can_be_excluded = true

func _ready() -> void:
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
        prevent_mouse_click = true
    panel_style = %PanelContainer.get_theme_stylebox("panel")

func _process(_delta: float) -> void:
    if !Controls.is_just_pressed(Controls.PlayerAction.ACCEPT) and !Controls.is_just_pressed(Controls.PlayerAction.EXCLUDE):
        prevent_mouse_click = false
    if block_focus or has_been_clicked:
        return

    if !excluded and is_accept_clicked():
        Sounds.click()
        has_been_clicked = true
        clicked.emit()

    if exclusion_can_be_changed() and is_exclude_clicked():
        Sounds.click()
        prevent_mouse_click = true
        excluded = !excluded
        excluded_changed.emit(excluded)

func exclusion_can_be_changed() -> bool:
    var exclusion_allowed = !has_been_clicked and can_be_excluded
    var player_has_enough_exclusions = PlayerService.lvl_up_exclusions_remaining > 0 or excluded # if choice is excluded, whatever the remaining exclusions, we want to allow de-excluding it
    return exclusion_allowed and player_has_enough_exclusions

func is_ui_accept() -> bool:
    return %PanelContainer.has_focus() and Input.is_action_pressed("ui_accept")

func is_accept_clicked() -> bool:
    return !prevent_mouse_click and is_hovered and Controls.is_just_pressed(Controls.PlayerAction.ACCEPT)

func is_exclude_clicked() -> bool:
    return !prevent_mouse_click and is_hovered and Controls.is_just_pressed(Controls.PlayerAction.EXCLUDE)

func refresh_display():
    var description = mod_definition.get_description()
    if !description.is_empty():
        %Description.text = description
        %Description.show()
    else:
        %Description.hide()

    %StatName.text = mod_definition.get_display_label()
    var value_label = str(ModsService.base_mod_values.get(mod_definition.name))
    if value_label.ends_with(".0"):
        value_label = value_label.split(".")[0]
    if !mod_definition.is_absolute:
        value_label += "%"
    if not (value_label.begins_with("-") or value_label.begins_with("0")):
        value_label = "+" + value_label
    %ModifierValue.text = value_label
    %Sprite.texture = mod_definition.sprite

func force_focus():
    %PanelContainer.grab_focus()

func disable():
    block_focus = true
    %PanelContainer.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
    %PanelContainer.mouse_default_cursor_shape = CursorShape.CURSOR_ARROW

func _on_panel_container_mouse_entered() -> void:
    if !block_focus and has_node("%PanelContainer"):
        is_hovered = true
        %PanelContainer.grab_focus()

func _on_panel_container_mouse_exited() -> void:
    if !block_focus and has_node("%PanelContainer"):
        is_hovered = false
        %PanelContainer.release_focus()

func _on_panel_container_focus_entered() -> void:
    if !block_focus:
        is_hovered = true
        Sounds.button_press()
        tween_borders_width(4)

func _on_panel_container_focus_exited() -> void:
    if !block_focus:
        is_hovered = false
        tween_borders_width(0)

func tween_borders_width(to: int):
    create_tween().tween_property(panel_style, "border_width_top", to, HOVER_ANIMATION_DURATION)
    create_tween().tween_property(panel_style, "border_width_bottom", to, HOVER_ANIMATION_DURATION)
    create_tween().tween_property(panel_style, "border_width_right", to, HOVER_ANIMATION_DURATION)
    create_tween().tween_property(panel_style, "border_width_left", to, HOVER_ANIMATION_DURATION)
