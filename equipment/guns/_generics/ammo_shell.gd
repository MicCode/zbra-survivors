extends Node2D

const ANIMATION_DURATION = 0.5
const LIFETIME = 1.0

var elapsed_time = 0.0
var started = false
var rotation_speed_rad_s = 100

func _ready():
    rotation_speed_rad_s += randf_range(-20, 20)
    %Path2D.scale.x = randf_range(0.9, 1.1)

func _process(delta: float) -> void:
    if started:
        elapsed_time += delta
        if elapsed_time > LIFETIME:
            %AnimationPlayer.play("fade")
        elif elapsed_time <= ANIMATION_DURATION:
            %Point.progress_ratio = elapsed_time / ANIMATION_DURATION
            %Sprite.global_position = %Point.global_position
            %Sprite.global_rotation += rotation_speed_rad_s * delta
            

func start_animation():
    started = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    if anim_name == "fade":
        queue_free()
