extends Node

var current_scene = null

func _ready() -> void:
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

## Change main scene according to given resource path and free current scene
func switch_to(scene_path: String) -> void:
	call_deferred("_deferred_switch_to", scene_path)

func _deferred_switch_to(scene_path: String) -> void:
	current_scene.free()
	var new_scene = load(scene_path)
	current_scene = new_scene.instantiate()
	get_tree().root.add_child(current_scene)
	get_tree().current_scene = current_scene