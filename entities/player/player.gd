extends CharacterBody2D
signal health_changed
signal health_depleted

@export var max_health = 100.0
@export var move_speed = 300.0
@export var health = 100.0

const DAMAGE_RATE = 50.0

var is_alive = true

func _ready():
	health = max_health
	update_health()
	
func _physics_process(delta):
	if is_alive:
		# Movements -----------------------------------------------------------------------------
		var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		var h_direction = Input.get_axis("move_left", "move_right")
		
		if h_direction != 0:
			%Sprite.flip_h = (h_direction != 1)
			
		velocity = direction * move_speed
		move_and_slide()
		if velocity.length() > 0:
			%Sprite.play("walk")
		else:
			%Sprite.play("idle")
		
		# Collisions -----------------------------------------------------------------------------
		var overlapping = %HurtBox.get_overlapping_bodies()
		if overlapping.size() > 0:
			health -= DAMAGE_RATE * overlapping.size() * delta
			%Health.current_health = health
			health_changed.emit(health)
			
			if health <= 0:
				health_depleted.emit()
				is_alive = false
				%Sprite.queue_free()
				%Gun.queue_free()
		

func update_health():
	%Health.max_health = max_health
	%Health.current_health = health
	health_changed.emit(health)
