extends CanvasLayer

var current_scene: Node = null
var transition_time = 0.5

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    var root = get_tree().root
    current_scene = root.get_child(root.get_child_count() - 1)

func _input(event):
    if event.is_action_pressed("screenshot"):
        take_screenshot()

func take_screenshot():
    await RenderingServer.frame_post_draw # Attend la fin du rendu
    var image: Image = get_viewport().get_texture().get_image()
    var datetime = Time.get_datetime_string_from_system().replace(":", "-")
    var path = "user://screenshot_%s.png" % datetime
    var response = image.save_png(path)

    if response == OK:
        print("Saved screenshot:", path)
    else:
        push_error("Failed to save screenshot: got response code [%d]" % response)

func switch_to(scene_path: String) -> void:
    current_scene.process_mode = Node.PROCESS_MODE_DISABLED

    var modulator = get_modulator(current_scene)
    var modulator_property = get_modulator_property(current_scene)
    if modulator and modulator_property and modulator[modulator_property]:
        var tween: Tween = get_tree().create_tween()
        modulator[modulator_property] = Color.WHITE
        tween.tween_property(modulator, modulator_property, Color.BLACK, transition_time / 2).connect("finished", func():
            call_deferred("_deferred_switch_to", scene_path)
        )
    else:
        call_deferred("_deferred_switch_to", scene_path)

func _deferred_switch_to(scene_path: String) -> void:
    print("Switch to scene: " + scene_path)
    current_scene.free()

    var new_scene = load(scene_path)
    current_scene = new_scene.instantiate()
    get_tree().root.add_child(current_scene)
    get_tree().current_scene = current_scene

    var modulator = get_modulator(current_scene)
    var modulator_property = get_modulator_property(current_scene)
    if modulator and modulator_property:
        modulator[modulator_property] = Color.BLACK
        get_tree().create_tween().tween_property(modulator, modulator_property, Color.WHITE, transition_time / 2)

func get_modulator(scene) -> Node2D:
    if scene is CanvasLayer:
        return scene.find_child("Modulator")
    elif scene is Node2D:
        return scene
    else:
        push_warning("Cannot find scene modulator")
        return null

func get_modulator_property(scene) -> String:
    if scene is CanvasLayer:
        return "color"
    elif scene is Node2D:
        return "modulate"
    else:
        push_warning("Cannot find scene modulator property")
        return ""
