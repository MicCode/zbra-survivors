extends CharacterBody2D
signal health_changed
signal health_depleted

@export var max_health = 100.0
@export var move_speed = 300.0
@export var health = 100.0

const DAMAGE_RATE = 50.0

var is_alive = true
var equiped_gun: Gun

func _ready():
	health = max_health
	init_health()
	
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
		var overlapping_ennemies = %HurtBox.get_overlapping_bodies()
		if overlapping_ennemies.size() > 0:
			health -= DAMAGE_RATE * overlapping_ennemies.size() * delta
			%Health.current_health = health
			health_changed.emit(health)
			
			if health <= 0:
				die()
		
		var overlapping_collectibles = %CollectRadius.get_overlapping_bodies()
		if overlapping_collectibles.size() > 0:
			for collectible in overlapping_collectibles:
				var equipment = LootTable.get_equipment(collectible)
				if equipment != null:
					if equipment is Gun && !equiped_gun:
						equiped_gun = equipment
						add_child(equiped_gun)
						collectible.queue_free()
		

func init_health():
	%Health.max_health = max_health
	%Health.current_health = health
	health_changed.emit(health)
	
func die():
	health_depleted.emit()
	is_alive = false
	%Sprite.queue_free()
	if equiped_gun != null:
		equiped_gun.queue_free()
