extends Node2D
signal depleted

@export var max_health: float = 100.0
@export var current_health: float = 100.0
@export var visible_bar = true

func _ready():
    current_health = max_health
    update_display()

func update_display():
    %Bar.max_value = max_health
    %Bar.value = current_health
    if visible_bar:
        %Bar.show()
    else:
        %Bar.hide()
    
func take_damage(damage: float):
    current_health -= damage
    %Bar.value = current_health
    
    if current_health <= 0:
        depleted.emit()
