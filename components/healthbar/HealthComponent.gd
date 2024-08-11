extends Node2D
signal depleted

@export var max_health = 100.0
@export var current_health = 100.0

func _ready():
	current_health = max_health
	%Bar.max_value = max_health
	%Bar.value = current_health
	
func take_damage(damage: int):
	current_health -= damage
	%Bar.value = current_health
	
	if current_health <= 0:
		emit_signal("depleted")
