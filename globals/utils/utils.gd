extends Node

func get_all_children_recursively(parent: Node, depth: int = 0) -> Array:
    var result := []
    for child in parent.get_children():
        result.append(child)
        if depth < 10:
            result += get_all_children_recursively(child, depth + 1)
    return result
