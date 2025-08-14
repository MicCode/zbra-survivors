extends Node

func get_all_children_recursively(parent: Node, depth: int = 0) -> Array:
    var result := []
    for child in parent.get_children():
        result.append(child)
        if depth < 10:
            result += get_all_children_recursively(child, depth + 1)
    return result

## Randomly pick one key from a chances dictionary, where keys are an enum value (int) and value a chance to be picked;
##  all weights are relative, meaning if they are all set to 1.0, all keys have the same chance to be picked
## [codeblock][/codeblock]
## Returned value is an int that must be cast back to the wanted enum (the one used as chances dictionary keys)
func weighted_pick(chances: Dictionary) -> int:
    var total_weight: float = 0.0
    for value in chances.values():
        total_weight += value
    var r: float = randf() * total_weight
    var cumulative: float = 0.0
    for key in chances.keys():
        cumulative += chances.get(key)
        if r <= cumulative:
            return key
    return chances.get(0) # fallback on first entry

func add_percent(value: float, percent: float) -> float:
    return value + ((value * percent) / 100)

func sub_percent(value: float, percent: float) -> float:
    return value - ((value * percent) / 100)

func get_scenes_inheriting(parent_scene_path: String, folder_path: String) -> Array[String]:
    var result: Array[String] = []
    var dir := DirAccess.open(folder_path)
    if dir == null:
        push_error("Impossible d'ouvrir le dossier : " + folder_path)
        return result

    dir.list_dir_begin()
    var file_name := dir.get_next()
    while file_name != "":
        if dir.current_is_dir():
            if file_name != "." and file_name != "..":
                result.append_array(get_scenes_inheriting(parent_scene_path, folder_path.path_join(file_name)))
        elif file_name.ends_with(".tscn"):
            var scene_path = folder_path.path_join(file_name)
            var file = FileAccess.open(scene_path, FileAccess.READ)
            if file:
                var content = file.get_as_text()
                file.close()
                if parent_scene_path in content:
                    result.append(file_name.replace(".tscn", "")) # ou scene_path si tu veux le chemin complet
        file_name = dir.get_next()
    dir.list_dir_end()

    return result
