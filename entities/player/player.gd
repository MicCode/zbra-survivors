extends CharacterBody2D
signal health_changed
signal health_depleted

@export var max_health = 100.0
@export var move_speed = 300.0
@export var health = 100.0

const DAMAGE_RATE = 50.0
const PICKUP_COOLDOWN_S = 0.5

var is_alive = true
var is_pickup_blocked = false
var equiped_gun: Gun

func _ready():
	health = max_health
	init_health()
	
func _physics_process(delta):
	if is_alive:
		move()
		check_for_ennemies(delta)
		check_for_collectibles()

func move():
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

func check_for_ennemies(delta):
	var overlapping_ennemies = %HurtBox.get_overlapping_bodies()
	if overlapping_ennemies.size() > 0:
		health -= DAMAGE_RATE * overlapping_ennemies.size() * delta
		%Health.current_health = health
		health_changed.emit(health)
		
		if health <= 0:
			die()

func check_for_collectibles():
	var overlapping_collectibles = %CollectRadius.get_overlapping_bodies()
	if overlapping_collectibles.size() > 0 && (Input.is_action_pressed("grab") || !equiped_gun):
		for collectible in overlapping_collectibles:
			if collectible is GunCollectible:
				equip_gun(collectible)

func equip_gun(collectible: Collectible):
	if is_pickup_blocked:
		return

	if equiped_gun:
		var collectible_to_drop = LootTable.to_collectible(equiped_gun)
		collectible_to_drop.global_position = global_position
		get_node("/root").add_child(collectible_to_drop)
		equiped_gun.queue_free()

	var new_gun = LootTable.to_equipment(collectible)
	equiped_gun = new_gun
	add_child(equiped_gun)
	block_pickup()
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


func block_pickup():
	is_pickup_blocked = true
	%PickUpTimer.start(PICKUP_COOLDOWN_S)

func _on_pick_up_timer_timeout():
	is_pickup_blocked = false
