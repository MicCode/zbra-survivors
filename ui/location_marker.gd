extends Node2D
class_name LocationMarker

@export var color: MarkerColors = MarkerColors.BLUE
@export var opacity: float = 1.0
@export var sprite_scale: float = 1.0

enum MarkerColors {
	BLUE,
	GREEN,
	RED
}
enum XDirections {
	RIGHT,
	CENTER_X,
	LEFT
}
enum YDirections {
	TOP,
	CENTER_Y,
	BOTTOM
}
const MARKER_PADDING = 20.0 # distance from nearest screen border (inside screen)

func _ready() -> void:
	%LocationMarker.modulate.a = opacity
	%LocationMarker.scale = Vector2(sprite_scale, sprite_scale)
	match color:
		MarkerColors.RED: %LocationMarker.texture = load("res://sprites/arrow-red.png")
		MarkerColors.GREEN: %LocationMarker.texture = load("res://sprites/arrow-green.png")
		_: %LocationMarker.texture = load("res://sprites/arrow-blue.png")

func _process(_delta: float) -> void:
	if %ScreenNotifier.is_on_screen():
		%LocationMarker.hide()
	else:
		update_maker_location()
		%LocationMarker.show()
		
func update_maker_location():
	var ctrans = get_canvas_transform()
	var view_size = get_viewport_rect().size / ctrans.get_scale()
	
	var bottom_left = (-ctrans.get_origin() / ctrans.get_scale())
	var top_right = bottom_left + view_size
	
	var x = global_position.x
	var y = global_position.y
	
	var marker_x = 0.0
	var x_direction: XDirections
	var y_direction: YDirections
	
	if x < bottom_left.x + MARKER_PADDING:
		marker_x = bottom_left.x + MARKER_PADDING
		x_direction = XDirections.LEFT
	elif x > top_right.x - MARKER_PADDING:
		marker_x = top_right.x - MARKER_PADDING
		x_direction = XDirections.RIGHT
	else:
		marker_x = x
		x_direction = XDirections.CENTER_X
		
	var marker_y = 0.0
	if y < bottom_left.y + MARKER_PADDING:
		marker_y = bottom_left.y + MARKER_PADDING
		y_direction = YDirections.TOP
	elif y > top_right.y - MARKER_PADDING:
		marker_y = top_right.y - MARKER_PADDING
		y_direction = YDirections.BOTTOM
	else:
		marker_y = y
		y_direction = YDirections.CENTER_Y
	
	%LocationMarker.global_position = Vector2(marker_x, marker_y)
	%LocationMarker.global_rotation = get_directional_rotation(x_direction, y_direction)

func get_directional_rotation(x_direction: XDirections, y_direction: YDirections) -> float:
	match x_direction:
		XDirections.LEFT:
			match y_direction:
				YDirections.TOP: return deg_to_rad(-45.0)
				YDirections.BOTTOM: return deg_to_rad(-135.0)
				_: return deg_to_rad(-90.0)
		XDirections.RIGHT:
			match y_direction:
				YDirections.TOP: return deg_to_rad(45.0)
				YDirections.BOTTOM: return deg_to_rad(135.0)
				_: return deg_to_rad(90.0)
		_:
			match y_direction:
				YDirections.TOP: return deg_to_rad(0.0)
				YDirections.BOTTOM: return deg_to_rad(180.0)
				_: return deg_to_rad(0.0)
