extends Node

var current_scene: CanvasItem = null
var transition_time = 0.5

func _ready() -> void:
    var root = get_tree().root
    current_scene = root.get_child(root.get_child_count() - 1)

func switch_to(scene_path: String) -> void:
    current_scene.process_mode = Node.PROCESS_MODE_DISABLED
    var tween: Tween = get_tree().create_tween()
    tween.tween_property(current_scene, "modulate", Color.BLACK, transition_time / 2).connect("finished", func():
        call_deferred("_deferred_switch_to", scene_path)
    )

func _deferred_switch_to(scene_path: String) -> void:
    current_scene.free()
    var new_scene = load(scene_path)
    current_scene = new_scene.instantiate()
    get_tree().root.add_child(current_scene)
    get_tree().current_scene = current_scene
    current_scene.modulate = Color.BLACK
    get_tree().create_tween().tween_property(current_scene, "modulate", Color.WHITE, transition_time / 2)
