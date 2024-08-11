extends CharacterBody2D

@export var max_health = 100.0
@export var move_speed = 300.0
@export var health = 100.0

var is_alive = true

func _ready():
	health = max_health
	
func _physics_process(delta):
	if is_alive:
		var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var h_direction = Input.get_axis("move_left", "move_right")
		
		if h_direction != 0:
			%Sprite.flip_h = (h_direction != 1)
			
		velocity = direction * move_speed
		move_and_slide()
		if velocity.length() > 0:
			$Sprite.play("walk")
		else:
			$Sprite.play("idle")
