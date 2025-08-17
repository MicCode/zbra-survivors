extends Node2D
class_name DangerZoneRect

const GRADIENT_OFFSET_START_POINT: float = 0.08
const GRADIENT_OFFSET_END_POINT: float = 0.8
const GRADIENT_COLOR_CURSOR: int = 1
const GRADIENT_OFFSET_CURSOR: int = 2

@onready var borders = %Borders
@onready var surface = %Surface
@onready var gradient: Gradient = _get_surface_gradient()

@export var animation_time: float = 2.0
@export var fade_time: float = 0.2
@export var width: float = 1000.0
@export var height: float = 60.0
@export var color: Color = Color.RED
@export var base_modulate: Color = Color.WHITE

var progress: float = GRADIENT_OFFSET_START_POINT
var track_player: bool = false

func _ready() -> void:
    _apply_display()
    modulate = Color.TRANSPARENT
    _apply_offset(GRADIENT_OFFSET_START_POINT)
    appear()

func appear():
    if fade_time > animation_time:
        fade_time = animation_time
    create_tween().tween_property(self, "modulate", base_modulate, fade_time)
    var progress_tween = create_tween()
    progress_tween.set_ease(Tween.EaseType.EASE_OUT)
    progress_tween.tween_property(self, "progress", GRADIENT_OFFSET_END_POINT, animation_time).finished.connect(disappear)

func disappear():
    create_tween().tween_property(self, "modulate", Color.TRANSPARENT, fade_time).finished.connect(func():
        call_deferred("queue_free")
    )

func _process(_delta: float) -> void:
    _apply_offset(progress)
    if track_player and PlayerService.player_instance:
        look_at(PlayerService.player_instance.global_position)

func _apply_offset(_offset: float):
    var offsets: PackedFloat32Array = gradient.offsets
    offsets.set(GRADIENT_OFFSET_CURSOR, _offset)
    gradient.offsets = offsets

func _apply_display():
    borders.size = Vector2(width, height)
    borders.position.y = - height / 2

    var borders_stylebox: StyleBoxFlat = borders.get_theme_stylebox("panel")
    borders_stylebox.border_color = color

    var colors: PackedColorArray = gradient.colors
    colors.set(GRADIENT_COLOR_CURSOR, Color(color, 0.5))
    colors.set(GRADIENT_OFFSET_CURSOR, Color(color, 0.25))
    gradient.colors = colors

func _get_surface_gradient() -> Gradient:
    var surface_stylebox: StyleBoxTexture = surface.get_theme_stylebox("panel")
    var surface_texture: GradientTexture1D = surface_stylebox.texture
    return surface_texture.gradient
