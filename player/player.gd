extends CharacterBody2D
class_name Player

signal health_depleted

const DAMAGE_RATE = 50.0
const PICKUP_COOLDOWN_S = 0.5
const XP_COLLECT_TIME = 3.0

var is_pickup_blocked = false
var equiped_gun: Gun
var can_be_damaged = true
var just_hurt = false

var effects_manager: PlayerEffectsManager

var actual_time_scale: float = 1.0
var time_scale_target: float = 1.0
var time_scale_change_interval: float = 0.01

var time_between_item_use = 0.5
var block_item_use = false

var dash_cooldown: SceneTreeTimer
var timewarp_ghost_interval: float = 0.05

func _ready():
    randomize()
    init_health()
    if Settings.WORLD_GENERATION_DEBUG:
        Settings.game_settings.camera_zoom = 0.1
        GameState.player_state.move_speed = 1000.0
    %Camera.zoom = Vector2(Settings.game_settings.camera_zoom, Settings.game_settings.camera_zoom)
    GameState.register_player_instance(self)
    GameState.player_state_changed.connect(_on_player_state_changed)
    GameState.player_gained_level.connect(_on_player_level_gained)
    GameState.equipped_gun_changed.connect(equip_gun)
    Minimap.track(self, Minimap.ObjectType.PLAYER)

    effects_manager = %EffectsManager

func _process(_delta: float) -> void:
    process_player_controls()
    if actual_time_scale != time_scale_target:
        if actual_time_scale < time_scale_target:
            actual_time_scale += time_scale_change_interval
        else:
            actual_time_scale -= time_scale_change_interval
        AudioServer.playback_speed_scale = actual_time_scale

func _physics_process(delta):
    if GameState.player_state.is_alive:
        move(delta)
        check_for_ennemies(delta)
        check_for_items()
        update_dash_gauge()
        check_for_xp()
        if effects_manager.has_effect(PlayerEffect.Effects.FIRE_RADIATION):
            burn_things_in_radius()

func move(_delta):
    var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var h_direction = Input.get_axis("move_left", "move_right")

    if h_direction != 0:
        %Sprite.flip_h = (h_direction != 1)

    if !%DashManager.is_dashing():
        velocity = direction * GameState.player_state.move_speed * GameState.player_state.move_speed_factor
    else:
        velocity = direction * GameState.player_state.move_speed * GameState.player_state.move_speed_factor * GameState.player_state.dash_speed_multiplier

    move_and_slide()
    Minimap.moved(self, position)
    GameState.player_moved.emit(position) # FIXME do not publish position each time ? set refresh interval ?
    if !just_hurt:
        if velocity.length() > 0:
            %Sprite.play("walk")
        else:
            %Sprite.play("idle")


func process_player_controls():
    if %DashManager.can_dash() and Controls.is_pressed(Controls.PlayerAction.DASH):
        %DashManager.start_dashing()
    if !block_item_use and GameState.consumable and Controls.is_pressed(Controls.PlayerAction.USE):
        var used_item = false
        if GameState.consumable is RadianceFlask:
            used_item = use_radiance_flask(GameState.consumable)
        elif GameState.consumable is TimewrapClock:
            used_item = use_timewrap_clock(GameState.consumable)
        elif GameState.consumable is Mine:
            used_item = use_mine(GameState.consumable)
        else:
            push_warning("Unknown consumable [%s]" % str(GameState.consumable))
        if used_item:
            GameState.change_consumable(null)
        get_tree().create_timer(time_between_item_use).timeout.connect(func():
            block_item_use = false
        )

#region Dash
func update_dash_gauge():
    var time_left = 0
    if %DashManager.dash_cooldown_timer:
        time_left = %DashManager.dash_cooldown_timer.time_left
    var gauge_value = floor((1 - (time_left / GameState.player_state.dash_cooldown)) * 5)
    if gauge_value != GameState.player_state.dash_gauge_value:
        GameState.player_state.dash_gauge_value = gauge_value
        GameState.emit_player_change()

func _on_dash_manager_is_dashing_changed(is_dashing: bool) -> void:
    set_invincible(is_dashing)
#endregion

func check_for_ennemies(_delta):
    var overlapping_ennemies = %HurtBox.get_overlapping_bodies()
    if overlapping_ennemies.size() > 0 && can_be_damaged:
        take_damage()

#region Damage
func take_damage(damage: int = 1):
    GameState.shake_screen.emit(10)
    GameState.player_state.health -= damage
    %Health.current_health = GameState.player_state.health
    GameState.emit_player_change()
    can_be_damaged = false
    get_tree().create_timer(GameState.player_state.damage_cooldown).timeout.connect(func():
        can_be_damaged = true
    )
    %Sprite.play("hurt")
    Sounds.player_hit()
    Controls.vibrate(0.5, 0.5, 1.0)
    just_hurt = true
    %HurtBox.set_collision_mask_value(2, false) # ennemies

    if GameState.player_state.health <= 0:
        die()
#endregion

#region Items pickup
func check_for_items():
    var overlapping_collectibles = %CollectRadius.get_overlapping_bodies()
    if overlapping_collectibles.size() > 0:
        for collectible in overlapping_collectibles:
            if collectible is GunCollectible:
                if Input.is_action_pressed("grab") || !equiped_gun:
                    compare_gun(collectible as GunCollectible)
            elif collectible is ConsumableItem:
                handle_collectible(collectible as ConsumableItem)

func compare_gun(collectible: GunCollectible):
    if is_pickup_blocked:
        return

    var change_menu = GameState.change_equipped_gun(GunService.create_gun(collectible.gun_stats.name))
    if !change_menu:
        free_collectible(collectible)
        return
    change_menu.take_pressed.connect(func():
        free_collectible(collectible)
    )

func equip_gun(new_gun: Gun):
    if equiped_gun:
        var collectible_to_drop = GunService.create_collectible(equiped_gun.gun_stats.name)
        collectible_to_drop.global_position = global_position
        SceneManager.current_scene.add_child(collectible_to_drop)
        equiped_gun.queue_free()
    equiped_gun = new_gun
    if new_gun:
        add_child(equiped_gun)
        Sounds.reload()

func free_collectible(collectible: GunCollectible):
    block_pickup()
    collectible.queue_free()
    Controls.vibrate(0.1, 0.5, 1.0)
    get_tree().create_timer(0.4).timeout.connect(func():
        Controls.vibrate(0.1, 0.5, 0.8)
    )

func handle_collectible(consumable: ConsumableItem):
    if consumable.stats.immediate_use:
        if consumable is LifeFlask:
            use_life_flask(consumable as LifeFlask)
        elif consumable is XpCollector:
            attract_all_xp_on_map(consumable)
    else:
        if !GameState.consumable or Controls.is_pressed(Controls.PlayerAction.GRAB):
            if is_pickup_blocked:
                return
            GameState.change_consumable(consumable)
            Sounds.reload()
            consumable.queue_free()
            block_pickup()

func check_for_xp():
    var overlapping_xp = %XpCollectRadius.get_overlapping_bodies()
    for xp in overlapping_xp:
        if xp is XpDrop && !xp.chase_player:
            xp.chase_player = true

func attract_all_xp_on_map(collector: XpCollector):
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

func use_life_flask(flask: LifeFlask):
    if GameState.player_state.health < GameState.player_state.max_health:
        GameState.player_state.health = min(GameState.player_state.health + flask.life_amount, GameState.player_state.max_health)
        GameState.emit_player_change()
        Sounds.heal()
        %Effects.show()
        %Effects.play("heal")
        flask.queue_free()
#endregion

func burn_things_in_radius():
    var bodies_in_radiance = %RadianceRadius.get_overlapping_bodies()
    for body in bodies_in_radiance:
        if body is EnvTree:
            if !body.is_destroyed:
                body.burn()
        elif body is Ennemy:
            if !body.is_dead && !body.is_burning:
                body.set_burning()

## Returns true if the item has been used
func use_radiance_flask(flask: RadianceFlask) -> bool:
    if effects_manager.has_effect(PlayerEffect.Effects.FIRE_RADIATION):
        return false
    effects_manager.add_effect(PlayerEffect.Effects.FIRE_RADIATION, flask.radiance_duration).finished.connect(func():
        %RadianceEffectAnimation.play("fadeout")
        %RadianceCollision.disabled = true
    )
    %RadianceEffectAnimation.play("fadein")
    %RadianceEffect.show()
    %RadianceCollision.disabled = false
    %Effects.show()
    %Effects.play("radiance")
    Sounds.start_burning()
    flask.queue_free()
    return true

## Returns true if the item has been used
func use_timewrap_clock(clock: TimewrapClock) -> bool:
    if effects_manager.has_effect(PlayerEffect.Effects.TIMEWARP):
        return false
    effects_manager.add_effect(PlayerEffect.Effects.TIMEWARP, clock.timewarp_duration * clock.timewarp_factor).finished.connect(func():
        Engine.time_scale = 1.0
        time_scale_target = 1.0
        Sounds.stop_timewarping()
        GameState.player_state.move_speed_factor = 1.0
        GameState.player_timewarping_changed.emit(false)
    )
    Engine.time_scale = clock.timewarp_factor
    time_scale_target = clock.timewarp_factor
    GameState.player_state.move_speed_factor = 1 / clock.timewarp_factor
    clock.queue_free()
    Sounds.start_timewarping()
    GameState.player_timewarping_changed.emit(true)
    create_timewarp_ghost()
    return true

func create_timewarp_ghost():
    get_tree().create_timer(timewarp_ghost_interval).timeout.connect(func():
        %DashManager.spawn_dash_ghost(1.0)
        if %EffectsManager.has_effect(PlayerEffect.Effects.TIMEWARP):
            create_timewarp_ghost()
    )

func use_mine(mine: Mine) -> bool:
    if !mine.can_be_used:
        return false

    mine.increment_use()
    GameState.consumable_use_changed.emit(mine.time_used)
    var new_mine = preload("res://items/droppables/land_mine.tscn").instantiate()
    new_mine.global_position = global_position
    SceneManager.current_scene.call_deferred("add_child", new_mine)
    Sounds.drop()

    return mine.time_used >= mine.stats.max_uses

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
    Sounds.player_die()
    VisualEffects.gore_death(%Sprite, 1.0).connect("finished", func():
        GameState.change_state(GameState.State.GAME_OVER)
    )


func block_pickup():
    is_pickup_blocked = true
    get_tree().create_timer(PICKUP_COOLDOWN_S).timeout.connect(func():
        is_pickup_blocked = false
    )

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
    %PlayerLevelManager.register_lvl_up()

func _on_effects_animation_finished() -> void:
    if !effects_manager.has_effect(PlayerEffect.Effects.FIRE_RADIATION):
        %Effects.hide()
        Sounds.stop_burning()
    else:
        %Effects.play("radiance")


func _on_radiance_effect_animation_animation_finished(anim_name: StringName) -> void:
    if anim_name == "fadein" && effects_manager.has_effect(PlayerEffect.Effects.FIRE_RADIATION):
        %RadianceEffectAnimation.play("radiate")
    elif anim_name == "fadeout":
        %RadianceEffect.hide()
