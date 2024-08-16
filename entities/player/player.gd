extends CharacterBody2D
signal health_depleted

const DAMAGE_RATE = 50.0
const PICKUP_COOLDOWN_S = 0.5

var is_pickup_blocked = false
var equiped_gun: Gun
var can_be_damaged = true

func _ready():
	init_health()
	
func _physics_process(delta):
	if GameState.player.is_alive:
		move()
		check_for_ennemies(delta)
		check_for_collectibles()
		update_dash_gauge()

func move():
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var h_direction = Input.get_axis("move_left", "move_right")
	if GameState.player.can_dash && Input.is_action_pressed("dash"):
		start_dashing()
	
	if h_direction != 0:
		%Sprite.flip_h = (h_direction != 1)
	
	if !GameState.player.is_dashing:
		velocity = direction * GameState.player.move_speed
	else:
		velocity = direction * GameState.player.move_speed * GameState.player.dash_speed_multiplier

	move_and_slide()
	if velocity.length() > 0:
		%Sprite.play("walk")
	else:
		%Sprite.play("idle")

func start_dashing():
	%DashSound.play()
	%DashTimer.start(GameState.player.dash_duration_s)
	%DashCooldownTimer.start(GameState.player.dash_cooldown_s)
	GameState.player.is_dashing = true
	GameState.player.can_dash = false
	set_invincible(true)
	GameState.emit_player_change()

func update_dash_gauge():
	var gauge_value = floor((1 - (%DashCooldownTimer.time_left / GameState.player.dash_cooldown_s)) * 5)
	if gauge_value != GameState.player.dash_gauge_value:
		GameState.player.dash_gauge_value = gauge_value
		GameState.emit_player_change()

func check_for_ennemies(delta):
	var overlapping_ennemies = %HurtBox.get_overlapping_bodies()
	if overlapping_ennemies.size() > 0 && can_be_damaged:
		take_damage()

func take_damage():
	GameState.player.health -= 1
	%Health.current_health = GameState.player.health
	GameState.emit_player_change()
	can_be_damaged = false
	%DamageTimer.start(GameState.player.damage_cooldown_s)
	
	if GameState.player.health <= 0:
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
		var collectible_to_drop = LootService.to_collectible(equiped_gun)
		collectible_to_drop.global_position = global_position
		get_node("/root").add_child(collectible_to_drop)
		equiped_gun.queue_free()

	var new_gun = LootService.to_equipment(collectible)
	equiped_gun = new_gun
	add_child(equiped_gun)
	block_pickup()
	collectible.queue_free()


func init_health():
	%Health.max_health = GameState.player.max_health
	%Health.current_health = GameState.player.health

	
func die():
	health_depleted.emit()
	GameState.player.is_alive = false
	GameState.emit_player_change()
	%Sprite.queue_free()
	if equiped_gun != null:
		equiped_gun.queue_free()


func block_pickup():
	is_pickup_blocked = true
	%PickUpTimer.start(PICKUP_COOLDOWN_S)

func _on_pick_up_timer_timeout():
	is_pickup_blocked = false


func _on_dash_cooldown_timer_timeout() -> void:
	if !GameState.player.can_dash:
		GameState.player.can_dash = true
		%DashReadySound.play()
		GameState.emit_player_change()

func _on_dash_timer_timeout() -> void:
	if GameState.player.is_dashing:
		GameState.player.is_dashing = false
		set_invincible(false)
		GameState.emit_player_change()

func _on_damage_timer_timeout() -> void:
	can_be_damaged = true

func set_invincible(invincible: bool):
	get_node("CollisionShape2D").disabled = invincible
	%HurtBox.get_node("shape").disabled = invincible
	if invincible:
		%Sprite.modulate.a = 0.5
	else:
		%Sprite.modulate.a = 1.0
