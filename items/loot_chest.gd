extends Node2D

const OPENING_TIME: float = 1.0
const DISAPPEAR_DELAY: float = 5.0

var is_open: bool = false

func _ready() -> void:
    var rays_shader: ShaderMaterial = %Rays.material
    rays_shader.set_shader_parameter("edge_fade", 0.4)
    rays_shader.set_shader_parameter("ray_2_intensity", 0.0)

func _process(_delta: float) -> void:
    var overlapping_env_element = %SafeArea.get_overlapping_bodies()
    for e in overlapping_env_element:
        if e is EnvTree:
            e.queue_free()

func _on_trigger_radius_body_entered(body: Node2D) -> void:
    if body == self:
        return
    if !is_open:
        %Sprite.play("open")
        Sounds.chest_open()
        var rays_shader: ShaderMaterial = %Rays.material
        create_tween().tween_property(rays_shader, "shader_parameter/edge_fade", 0.15, OPENING_TIME)
        create_tween().tween_property(rays_shader, "shader_parameter/ray_2_intensity", 0.7, OPENING_TIME).finished.connect(func():
            GameState.player_openned_chest.emit()
        )
        is_open = true
        get_tree().create_timer(DISAPPEAR_DELAY).timeout.connect(disappear)

func disappear():
    var rays_shader: ShaderMaterial = %Rays.material
    create_tween().tween_property(rays_shader, "shader_parameter/edge_fade", 1.0, OPENING_TIME)
    create_tween().tween_property(rays_shader, "shader_parameter/ray_2_intensity", 0.0, OPENING_TIME)
    create_tween().tween_property(self, "modulate", Color.TRANSPARENT, OPENING_TIME).finished.connect(func():
        queue_free()
    )
