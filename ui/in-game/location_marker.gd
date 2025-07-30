extends Node2D
class_name LocationMarker

@export var color: MarkerColors = MarkerColors.BLUE
@export var opacity: float = 1.0
@export var sprite_scale: float = 1.0

enum MarkerColors {
    BLUE,
    GREEN,
    RED,
    GOLD,
}
enum XDir {
    RIGHT,
    CENTER_X,
    LEFT
}
enum YDir {
    TOP,
    CENTER_Y,
    BOTTOM
}
const MARKER_PADDING = 200.0 # distance from nearest screen border (inside screen)

func _ready() -> void:
    %LocationMarker.modulate.a = opacity
    %LocationMarker.scale = Vector2(sprite_scale, sprite_scale)
    match color:
        MarkerColors.RED: %LocationMarker.texture = load("res://assets/sprites/arrow-red.png")
        MarkerColors.GREEN: %LocationMarker.texture = load("res://assets/sprites/arrow-green.png")
        MarkerColors.GOLD: %LocationMarker.texture = load("res://assets/sprites/arrow-gold.png")
        _: %LocationMarker.texture = load("res://assets/sprites/arrow-blue.png")

func _process(_delta: float) -> void:
    if %ScreenNotifier.is_on_screen():
        %LocationMarker.hide()
    else:
        update_maker_location()
        %LocationMarker.show()

func update_maker_location():
    var ctrans = get_canvas_transform()
    var view_size = get_viewport_rect().size / ctrans.get_scale()

    var bottom_left = - ctrans.get_origin() / ctrans.get_scale()
    var top_right = bottom_left + view_size

    var x = global_position.x
    var y = global_position.y

    var marker_x = 0.0
    var x_direction: XDir
    var y_direction: YDir

    if x < bottom_left.x + MARKER_PADDING:
        marker_x = bottom_left.x + MARKER_PADDING
        x_direction = XDir.LEFT
    elif x > top_right.x - MARKER_PADDING:
        marker_x = top_right.x - MARKER_PADDING
        x_direction = XDir.RIGHT
    else:
        marker_x = x
        x_direction = XDir.CENTER_X

    var marker_y = 0.0
    if y < bottom_left.y + MARKER_PADDING:
        marker_y = bottom_left.y + MARKER_PADDING
        y_direction = YDir.TOP
    elif y > top_right.y - MARKER_PADDING:
        marker_y = top_right.y - MARKER_PADDING
        y_direction = YDir.BOTTOM
    else:
        marker_y = y
        y_direction = YDir.CENTER_Y

    %LocationMarker.global_position = Vector2(marker_x, marker_y)
    %LocationMarker.global_rotation = get_directional_rotation(x_direction, y_direction)

func get_directional_rotation(x_direction: XDir, y_direction: YDir) -> float:
    if x_direction == XDir.CENTER_X:
        match y_direction:
            YDir.TOP: return deg_to_rad(0.0)
            YDir.BOTTOM: return deg_to_rad(180.0)
            _: return deg_to_rad(0.0)
    else:
        var flip = 1 if x_direction == XDir.RIGHT else -1
        match y_direction:
            YDir.TOP: return deg_to_rad(45.0 * flip)
            YDir.BOTTOM: return deg_to_rad(135.0 * flip)
            _: return deg_to_rad(90.0 * flip)
