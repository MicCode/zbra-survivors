extends CharacterBody2D
class_name XpDrop

var chase_player = false
@export var xp_value: float = 1.0

func with_value(_value: float) -> XpDrop:
	xp_value = _value
	return self

func _physics_process(_delta: float) -> void:
	if chase_player:
		var player_position = GameService.player_instance.global_position
		var direction_to_player = global_position.direction_to(player_position)
		velocity = direction_to_player * 1000.0
		move_and_slide()
		if abs((global_position - player_position).length()) < 10:
			GameService.gain_xp(xp_value)
			queue_free()
