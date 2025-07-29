extends Control
class_name LvlUpChoice

signal clicked

const HOVER_ANIMATION_DURATION = 0.1
var panel_style: StyleBoxFlat
var has_been_clicked = false
var block_focus = false
var stat_modifier: PlayerStatModifier # TODO add a more generic class to also support GunStatModifiers ?

func _ready() -> void:
    panel_style = %PanelContainer.get_theme_stylebox("panel")

func _process(_delta: float) -> void:
    if block_focus or has_been_clicked:
        return
    if %PanelContainer.has_focus() and (Input.is_action_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
        Sounds.coin()
        has_been_clicked = true
        clicked.emit()

func set_stat_modifier(new_modifier: PlayerStatModifier):
    stat_modifier = new_modifier.duplicate(true) as PlayerStatModifier
    %StatName.text = tr(str("LABEL_%s" % new_modifier.stat_name).to_upper()) # TODO extract label building to a dedicated global function ?
    var value_label = str(new_modifier.modifier_value)
    if value_label.ends_with(".0"):
        value_label = value_label.split(".")[0]
    if !new_modifier.is_absolute:
        value_label += "%"
    if not (value_label.begins_with("-") or value_label.begins_with("0")):
        value_label = "+" + value_label
    %ModifierValue.text = value_label
    # TODO change displayed texture in %Sprite in function of the modifier. Extract this texture-modifier association in a global service ?

func force_focus():
    %PanelContainer.grab_focus()

func disable():
    block_focus = true
    %PanelContainer.mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE
    %PanelContainer.mouse_default_cursor_shape = CursorShape.CURSOR_ARROW

func _on_panel_container_mouse_entered() -> void:
    if !block_focus:
        %PanelContainer.grab_focus()

func _on_panel_container_mouse_exited() -> void:
    if !block_focus:
        %PanelContainer.release_focus()

func _on_panel_container_focus_entered() -> void:
    if !block_focus:
        Sounds.click()
        tween_borders_width(4)

func _on_panel_container_focus_exited() -> void:
    if !block_focus:
        tween_borders_width(0)

func tween_borders_width(to: int):
    get_tree().create_tween().tween_property(panel_style, "border_width_top", to, HOVER_ANIMATION_DURATION)
    get_tree().create_tween().tween_property(panel_style, "border_width_bottom", to, HOVER_ANIMATION_DURATION)
    get_tree().create_tween().tween_property(panel_style, "border_width_right", to, HOVER_ANIMATION_DURATION)
    get_tree().create_tween().tween_property(panel_style, "border_width_left", to, HOVER_ANIMATION_DURATION)
