extends CharacterBody2D
class_name Player

signal health_depleted

var camera_zoom = 1.3 # for debug purpose set to 1.0 in normal condition TODO set this in game settings ?

const DAMAGE_RATE = 50.0
const PICKUP_COOLDOWN_S = 0.5
const DASH_GHOST_INTERVAL_S = 0.01
const XP_COLLECT_TIME = 3.0

var is_pickup_blocked = false
var equiped_gun: Gun
var can_be_damaged = true
var just_hurt = false

var is_radiating = false
var radiance_duration_s: float = 5.0

var is_timewrapping = false
var timewrap_duration_s: float = 5.0
var timewrap_time_scale: float = 0.5
var actual_time_scale: float = 1.0
var time_scale_target: float = 1.0
var time_scale_change_interval: float = 0.01

var time_between_item_use = 0.5
var block_item_use = false

func _ready():
	randomize()
	init_health()
	if Settings.WORLD_GENERATION_DEBUG:
		camera_zoom = 0.1
		GameService.player_state.move_speed = 1000.0
	%Camera.zoom = Vector2(camera_zoom, camera_zoom)
	GameService.register_player_instance(self)
	GameService.player_state_changed.connect(_on_player_state_changed)
	GameService.player_gained_level.connect(_on_player_level_gained)
	Minimap.track(self, Minimap.ObjectType.PLAYER)

func _process(_delta: float) -> void:
	execute_player_commands()
	if actual_time_scale != time_scale_target:
		if actual_time_scale < time_scale_target:
			actual_time_scale += time_scale_change_interval
		else:
			actual_time_scale -= time_scale_change_interval
		AudioServer.playback_speed_scale = actual_time_scale

func _physics_process(delta):
	if GameService.player_state.is_alive:
		move(delta)
		check_for_ennemies(delta)
		check_for_collectibles()
		if is_radiating:
			burn_things()
		update_dash_gauge()
		collect_xp()

func move(_delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var h_direction = Input.get_axis("move_left", "move_right")

	if h_direction != 0:
		%Sprite.flip_h = (h_direction != 1)

	if !GameService.player_state.is_dashing:
		velocity = direction * GameService.player_state.move_speed
	else:
		velocity = direction * GameService.player_state.move_speed * GameService.player_state.dash_speed_multiplier

	move_and_slide()
	Minimap.moved(self, position)
	GameService.player_moved.emit(position) # FIXME do not publish position each time ? set refresh interval ?
	if !just_hurt:
		if velocity.length() > 0:
			%Sprite.play("walk")
		else:
			%Sprite.play("idle")

func execute_player_commands():
	if GameService.player_state.can_dash and Controls.is_pressed(Controls.PlayerAction.DASH):
		start_dashing()
	if !block_item_use and GameService.consumable and Controls.is_pressed(Controls.PlayerAction.USE):
		var used_item = false
		if GameService.consumable is RadianceFlask:
			used_item = use_radiance_flask(GameService.consumable)
		elif GameService.consumable is TimewrapClock:
			used_item = use_timewrap_clock(GameService.consumable)
		elif GameService.consumable is Mine:
			used_item = use_mine(GameService.consumable)
		else:
			push_warning("Unknown consumable [%s]" % str(GameService.consumable))
		if used_item:
			GameService.change_consumable(null)
		get_tree().create_timer(time_between_item_use).timeout.connect(func():
			block_item_use = false
		)

func start_dashing():
	Sounds.dash()
	%DashTimer.start(GameService.player_state.dash_duration_s)
	%DashCooldownTimer.start(GameService.player_state.dash_cooldown_s)
	GameService.player_state.is_dashing = true
	GameService.player_state.can_dash = false
	set_invincible(true)
	GameService.emit_player_change()
	%DashGhostTimer.start(DASH_GHOST_INTERVAL_S)

func update_dash_gauge():
	var gauge_value = floor((1 - (%DashCooldownTimer.time_left / GameService.player_state.dash_cooldown_s)) * 5)
	if gauge_value != GameService.player_state.dash_gauge_value:
		GameService.player_state.dash_gauge_value = gauge_value
		GameService.emit_player_change()

func check_for_ennemies(_delta):
	var overlapping_ennemies = %HurtBox.get_overlapping_bodies()
	if overlapping_ennemies.size() > 0 && can_be_damaged:
		take_damage()

func take_damage(damage: int = 1):
	GameService.shake_screen.emit(10)
	GameService.player_state.health -= damage
	%Health.current_health = GameService.player_state.health
	GameService.emit_player_change()
	can_be_damaged = false
	%DamageTimer.start(GameService.player_state.damage_cooldown_s)
	%Sprite.play("hurt")
	Sounds.player_hit()
	just_hurt = true
	%HurtBox.set_collision_mask_value(2, false) # ennemies

	if GameService.player_state.health <= 0:
		die()

func check_for_collectibles():
	var overlapping_collectibles = %CollectRadius.get_overlapping_bodies()
	if overlapping_collectibles.size() > 0:
		for collectible in overlapping_collectibles:
			if collectible is GunCollectible:
				if Input.is_action_pressed("grab") || !equiped_gun:
					equip_gun(collectible as GunCollectible)
			elif collectible is ConsumableItem:
				handle_consumable(collectible as ConsumableItem)

func handle_consumable(consumable: ConsumableItem):
	if consumable.stats.immediate_use:
		if consumable is LifeFlask:
			collect_life_flask(consumable as LifeFlask)
		elif consumable is XpCollector:
			collect_all_xp_on_map(consumable)
	else:
		if !GameService.consumable or Controls.is_pressed(Controls.PlayerAction.GRAB):
			if is_pickup_blocked:
				return
			GameService.change_consumable(consumable)
			Sounds.reload()
			consumable.queue_free()
			block_pickup()

func burn_things():
	var bodies_in_radiance = %RadianceRadius.get_overlapping_bodies()
	for body in bodies_in_radiance:
		if body is EnvTree:
			if !body.is_destroyed:
				body.burn()
		elif body is Ennemy:
			if !body.is_dead && !body.is_burning:
				body.set_burning()

func collect_xp():
	var overlapping_xp = %XpCollectRadius.get_overlapping_bodies()
	for xp in overlapping_xp:
		if xp is XpDrop && !xp.chase_player:
			xp.chase_player = true


func equip_gun(collectible: GunCollectible):
	if is_pickup_blocked:
		return

	if equiped_gun:
		var collectible_to_drop = GunService.create_collectible(equiped_gun.gun_stats.name)
		collectible_to_drop.global_position = global_position
		SceneManager.current_scene.add_child(collectible_to_drop)
		equiped_gun.queue_free()

	var new_gun = GunService.create_gun(collectible.gun_stats.name)
	equiped_gun = new_gun
	add_child(equiped_gun)
	Sounds.reload()
	GameService.change_equipped_gun(equiped_gun)
	block_pickup()
	collectible.queue_free()

func collect_all_xp_on_map(collector: XpCollector):
	Sounds.absorb()
	%VisualEffects.start_effect("absorb_xp", preload("res://effects/absorb_xp.tscn"))
	collector.queue_free()
	get_tree().create_timer(XP_COLLECT_TIME).connect("timeout", func():
		%VisualEffects.stop_effect("absorb_xp")
	)
	var children = SceneManager.current_scene.get_children()
	for child in children:
		if child is XpDrop:
			child.move_to_player()


func collect_life_flask(flask: LifeFlask):
	if GameService.player_state.health < GameService.player_state.max_health:
		GameService.player_state.health = min(GameService.player_state.health + flask.life_amount, GameService.player_state.max_health)
		GameService.emit_player_change()
		Sounds.heal()
		%Effects.show()
		%Effects.play("heal")
		flask.queue_free()

## Returns true if the item has been used
func use_radiance_flask(flask: RadianceFlask) -> bool:
	if is_radiating:
		return false
	is_radiating = true
	%RadianceEffectAnimation.play("fadein")
	%RadianceEffect.show()
	%RadianceTimer.start(radiance_duration_s)
	%RadianceCollision.disabled = false
	%Effects.show()
	%Effects.play("radiance")
	Sounds.start_burning()
	flask.queue_free()
	return true

## Returns true if the item has been used
func use_timewrap_clock(clock: TimewrapClock) -> bool:
	if is_timewrapping:
		return false
	is_timewrapping = true
	%TimewrapTimer.start(timewrap_duration_s * timewrap_time_scale)
	Engine.time_scale = timewrap_time_scale
	time_scale_target = timewrap_time_scale
	GameService.player_state.move_speed /= (timewrap_time_scale * 1.5)
	clock.queue_free()
	Sounds.start_timewarping()
	GameService.player_timewarping_changed.emit(true)
	return true

func use_mine(mine: Mine) -> bool:
	if !mine.can_be_used:
		return false

	mine.increment_use()
	GameService.consumable_use_changed.emit(mine.time_used)
	var new_mine = preload("res://equipment/items/droppables/land_mine.tscn").instantiate()
	new_mine.global_position = global_position
	SceneManager.current_scene.call_deferred("add_child", new_mine)
	Sounds.drop()

	return mine.time_used >= mine.stats.max_uses

func _on_timewrap_timer_timeout() -> void:
	Engine.time_scale = 1.0
	is_timewrapping = false
	time_scale_target = 1.0
	GameService.player_state.move_speed *= (timewrap_time_scale * 1.5)
	Sounds.stop_timewarping()
	GameService.player_timewarping_changed.emit(false)

func init_health():
	%Health.max_health = GameService.player_state.max_health
	%Health.current_health = GameService.player_state.health

func die():
	health_depleted.emit()
	GameService.player_state.is_alive = false
	GameService.emit_player_change()
	if equiped_gun != null:
		equiped_gun.queue_free()
	%Sprite.play("dead")
	Sounds.player_die()
	VisualEffects.gore_death(%Sprite, 1.0).connect("finished", func(): GameService.set_game_over(true))


func block_pickup():
	is_pickup_blocked = true
	%PickUpTimer.start(PICKUP_COOLDOWN_S)

func _on_pick_up_timer_timeout():
	is_pickup_blocked = false


func _on_dash_cooldown_timer_timeout() -> void:
	if !GameService.player_state.can_dash:
		GameService.player_state.can_dash = true
		Sounds.dash_ready()
		GameService.emit_player_change()

func _on_dash_timer_timeout() -> void:
	if GameService.player_state.is_dashing:
		GameService.player_state.is_dashing = false
		set_invincible(false)
		GameService.emit_player_change()

func _on_dash_ghost_timer_timeout() -> void:
	if GameService.player_state.is_dashing:
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
	set_collision_mask_value(2, !invincible) # ennemies layer
	set_collision_mask_value(3, !invincible) # environment layer
	set_collision_mask_value(8, !invincible) # radiance layer
	%HurtBox.get_node("shape").disabled = invincible
	if invincible:
		%Sprite.modulate.a = 0.5
	else:
		%Sprite.modulate.a = 1.0

func _on_sprite_animation_finished() -> void:
	if just_hurt:
		just_hurt = false
		%HurtBox.set_collision_mask_value(2, true) # ennemies
		%Sprite.play("idle")

func _on_player_state_changed(player_state: PlayerState) -> void:
	%XpCollectShape.shape.radius = player_state.xp_collect_radius

func _on_player_level_gained(_new_level: int):
	%Effects.show()
	%Effects.play("lvlup")
	Sounds.level_up()

func _on_effects_animation_finished() -> void:
	if !is_radiating:
		%Effects.hide()
		Sounds.stop_burning()
	else:
		%Effects.play("radiance")

func _on_lvl_up_effect_animation_animation_finished(_anim_name: StringName) -> void:
	%LvlUpEffectLight.hide()


func _on_radiance_effect_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fadein" && is_radiating:
		%RadianceEffectAnimation.play("radiate")
	elif anim_name == "fadeout":
		%RadianceEffect.hide()


func _on_radiance_timer_timeout() -> void:
	if is_radiating:
		is_radiating = false
		%RadianceEffectAnimation.play("fadeout")
		%RadianceCollision.disabled = true
