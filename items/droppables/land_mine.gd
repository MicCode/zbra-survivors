extends CharacterBody2D
class_name LandMine

var time_to_set_up = 0.25
var time_to_explode = 0.5
var triggered = false
var exploded = false
var ready_to_explode = false

func _ready() -> void:
    modulate = Color.DARK_RED
    get_tree().create_timer(time_to_set_up).timeout.connect(func():
        modulate = Color.WHITE
        ready_to_explode = true
        Sounds.button_press()
    )

func _on_detection_area_body_entered(_body: Node2D) -> void:
    if ready_to_explode:
        trigger()

func _on_detection_area_area_entered(area: Area2D) -> void:
    if ready_to_explode:
        trigger(area is Bullet)

func explode():
    if !exploded:
        exploded = true
        call_deferred("create_explosive_effect")

func create_explosive_effect():
    var explosive_effect: ExplosiveEffect = preload("res://effects/explosive_effect.tscn").instantiate()
    explosive_effect.global_position = global_position
    SceneManager.current_scene.add_child(explosive_effect)
    explosive_effect.explode()
    explosive_effect.explosion_finished.connect(func():
        queue_free()
    )

func trigger(immediate: bool = false):
    if !triggered:
        triggered = true
        Sounds.toggle()
        if immediate:
            call_deferred("explode")
        else:
            get_tree().create_timer(time_to_explode).timeout.connect(func():
                call_deferred("explode")
            )
