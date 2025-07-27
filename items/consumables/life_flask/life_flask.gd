extends ConsumableItem
class_name LifeFlask

var life_amount: int = 1

func with_life_amount(_life_amount: int) -> LifeFlask:
    life_amount = _life_amount
    return self
