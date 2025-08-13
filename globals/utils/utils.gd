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