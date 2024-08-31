extends CharacterBody2D
class_name Player

signal health_depleted

const DAMAGE_RATE = 50.0
const PICKUP_COOLDOWN_S = 0.5
const DASH_GHOST_INTERVAL_S = 0.01

var is_pickup_blocked = false
var equiped_gun: Gun
var can_be_damaged = true
var just_hurt = false

func _ready():
	init_health()
	GameState.register_player_instance(self)
	GameState.player_state_changed.connect(_on_player_state_changed)
	GameState.player_gained_level.connect(_on_player_level_gained)
	
func _physics_process(delta):
	if GameState.player_state.is_alive:
		move()
		check_for_ennemies(delta)
		check_for_collectibles()
		update_dash_gauge()
		collect_xp()

func move():
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var h_direction = Input.get_axis("move_left", "move_right")
	if GameState.player_state.can_dash && Input.is_action_pressed("dash"):
		start_dashing()
	
	if h_direction != 0:
		%Sprite.flip_h = (h_direction != 1)
	
	if !GameState.player_state.is_dashing:
		velocity = direction * GameState.player_state.move_speed
	else:
		velocity = direction * GameState.player_state.move_speed * GameState.player_state.dash_speed_multiplier

	move_and_slide()
	if !just_hurt:
		if velocity.length() > 0:
			%Sprite.play("walk")
		else:
			%Sprite.play("idle")

func start_dashing():
	%DashSound.play()
	%DashTimer.start(GameState.player_state.dash_duration_s)
	%DashCooldownTimer.start(GameState.player_state.dash_cooldown_s)
	GameState.player_state.is_dashing = true
	GameState.player_state.can_dash = false
	set_invincible(true)
	GameState.emit_player_change()
	%DashGhostTimer.start(DASH_GHOST_INTERVAL_S)

func update_dash_gauge():
	var gauge_value = floor((1 - (%DashCooldownTimer.time_left / GameState.player_state.dash_cooldown_s)) * 5)
	if gauge_value != GameState.player_state.dash_gauge_value:
		GameState.player_state.dash_gauge_value = gauge_value
		GameState.emit_player_change()

func check_for_ennemies(_delta):
	var overlapping_ennemies = %HurtBox.get_overlapping_bodies()
	if overlapping_ennemies.size() > 0 && can_be_damaged:
		take_damage()

func take_damage():
	GameState.player_state.health -= 1
	%Health.current_health = GameState.player_state.health
	GameState.emit_player_change()
	can_be_damaged = false
	%DamageTimer.start(GameState.player_state.damage_cooldown_s)
	%Sprite.play("hurt")
	%HitSound.play()
	just_hurt = true
	
	if GameState.player_state.health <= 0:
		die()

func check_for_collectibles():
	var overlapping_collectibles = %CollectRadius.get_overlapping_bodies()
	if overlapping_collectibles.size() > 0 && (Input.is_action_pressed("grab") || !equiped_gun):
		for collectible in overlapping_collectibles:
			if collectible is GunCollectible:
				equip_gun(collectible)
				
func collect_xp():
	var overlapping_xp = %XpCollectRadius.get_overlapping_bodies()
	for xp in overlapping_xp:
		if xp is XpDrop && !xp.chase_player:
			xp.chase_player = true

func equip_gun(collectible: CollectibleItem):
	if is_pickup_blocked:
		return

	if equiped_gun:
		var collectible_to_drop = EquipmentService.to_collectible(equiped_gun)
		collectible_to_drop.global_position = global_position
		SceneManager.current_scene.add_child(collectible_to_drop)
		equiped_gun.queue_free()

	var new_gun = EquipmentService.to_equipment(collectible)
	equiped_gun = new_gun
	add_child(equiped_gun)
	GameState.change_equipped_gun(equiped_gun)
	block_pickup()
	collectible.queue_free()


func init_health():
	%Health.max_health = GameState.player_state.max_health
	%Health.current_health = GameState.player_state.health

func die():
	health_depleted.emit()
	GameState.player_state.is_alive = false
	GameState.emit_player_change()
	if equiped_gun != null:
		equiped_gun.queue_free()
	%Sprite.play("dead")
	GameState.is_game_over = true


func block_pickup():
	is_pickup_blocked = true
	%PickUpTimer.start(PICKUP_COOLDOWN_S)

func _on_pick_up_timer_timeout():
	is_pickup_blocked = false


func _on_dash_cooldown_timer_timeout() -> void:
	if !GameState.player_state.can_dash:
		GameState.player_state.can_dash = true
		%DashReadySound.play()
		GameState.emit_player_change()

func _on_dash_timer_timeout() -> void:
	if GameState.player_state.is_dashing:
		GameState.player_state.is_dashing = false
		set_invincible(false)
		GameState.emit_player_change()
		
func _on_dash_ghost_timer_timeout() -> void:
	if GameState.player_state.is_dashing:
		var ghost = preload("res://player/dash_ghost.tscn").instantiate()
		ghost.global_position = global_position
		ghost.global_rotation = global_rotation
		ghost.global_scale = global_scale * 1.5 # because sprite is also internally scaled by 1.5
		ghost.z_index = -1
		SceneManager.current_scene.add_child(ghost)
		%DashGhostTimer.start(DASH_GHOST_INTERVAL_S)

func _on_damage_timer_timeout() -> void:
	can_be_damaged = true

func set_invincible(invincible: bool):
	get_node("CollisionShape2D").disabled = invincible
	%HurtBox.get_node("shape").disabled = invincible
	if invincible:
		%Sprite.modulate.a = 0.5
	else:
		%Sprite.modulate.a = 1.0

func _on_sprite_animation_finished() -> void:
	if just_hurt:
		just_hurt = false
		%Sprite.play("idle")

func _on_player_state_changed(player_state: PlayerState) -> void:
	%XpCollectShape.shape.radius = player_state.xp_collect_radius
	
func _on_player_level_gained(_new_level: int):
	%Effects.show()
	%Effects.play("lvlup")
	%LvlUpSound.play()

func _on_effects_animation_finished() -> void:
	%Effects.hide()
