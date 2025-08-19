extends Node2D
class_name Weapon

@export var weapon_stats: WeaponStats
@export var bullet_stats: BulletStats

var cooling_down = false
var sound_cooldown = false
var flipped = false
var flip_vertical = false
var initial_x_position: float
var ignore_spread = false

func _enter_tree() -> void:
    if !weapon_stats:
        push_warning("weapon has no weapon_stats defined, falling back to default")
        weapon_stats = load("res://items/weapons/_generics/stats/default_weapon_stats.tres")
    if !bullet_stats:
        push_warning("weapon has no bullet_stats defined, falling back to default")
        bullet_stats = load("res://items/weapons/_generics/stats/default_bullet_stats.tres")

func _ready():
    if !has_node("%Sprite"): push_error("Weapon scene has no unique identifier %Sprite defined")
    if !has_node("%ShootingPoint"): push_error("Weapon scene has no unique identifier %ShootingPoint defined")
    if !has_node("%CooldownProgress"): push_error("Weapon scene has no unique identifier %CooldownProgress defined")
    if !has_node("%CooldownTimer"): push_error("Weapon scene has no unique identifier %CooldownTimer defined")

    WeaponService.weapon_stats_changed.connect(func(new_stats: WeaponStats):
        weapon_stats = new_stats.duplicate(true)
        update_from_stats()
    )
    WeaponService.bullet_stats_changed.connect(func(new_stats: BulletStats):
        bullet_stats = new_stats.duplicate(true)
        update_from_stats()
    )
    (%Sprite as AnimatedSprite2D).animation_finished.connect(_on_sprite_animation_finished)
    (%CooldownTimer as Timer).timeout.connect(_on_cooldown_timer_timeout)

    initial_x_position = (%Sprite as AnimatedSprite2D).position.x
    update_from_stats()

func update_from_stats():
    var guides = %AimGuides as AimGuides
    guides.set_dispersion_angle(weapon_stats.bullets_spread_angle_deg)

    var frames: SpriteFrames = (%Sprite as AnimatedSprite2D).sprite_frames
    if frames.has_animation("firing"):
        var firing_frames_count = frames.get_frame_count("firing")
        var fps = weapon_stats.shots_per_s * firing_frames_count
        frames.set_animation_speed("firing", fps)

func _process(_delta):
    %CooldownProgress.value = %CooldownTimer.time_left
    if Controls.is_pressed(Controls.PlayerAction.SHOOT):
        shoot()
    move_target()

func _physics_process(_delta):
    if self.global_rotation_degrees > 90 || self.global_rotation_degrees < -90:
        if !flipped:
            flipped = true
            if flip_vertical: (%Sprite as AnimatedSprite2D).rotation_degrees += 90
            (%Sprite as AnimatedSprite2D).scale = Vector2(1, -1)
    else:
        if flipped:
            flipped = false
            if flip_vertical: (%Sprite as AnimatedSprite2D).rotation_degrees -= 90
            (%Sprite as AnimatedSprite2D).scale = Vector2(1, 1)

func _on_sprite_animation_finished():
    (%Sprite as AnimatedSprite2D).play("idle")

func _on_cooldown_timer_timeout():
    if cooling_down:
        if !Controls.is_pressed(Controls.PlayerAction.SHOOT):
            (%Sprite as AnimatedSprite2D).play("idle")
        cooling_down = false

func move_target():
    var joypads = Input.get_connected_joypads()
    if joypads.size() > 0:
        var joystick_direction = Input.get_vector("look_left", "look_right", "look_up", "look_down")
        var look_point = global_position + joystick_direction
        look_at(look_point)
    else:
        look_at(get_global_mouse_position())

func shoot() -> bool:
    if !cooling_down:
        spawn_projectiles()
        (%Sprite as AnimatedSprite2D).play("firing")
        (%Sprite as AnimatedSprite2D).set_frame_and_progress(0, 0)
        if !sound_cooldown:
            Sounds.shoot(weapon_stats.shoot_sfx_options, weapon_stats.shoot_sound)
            sound_cooldown = true
            var cooldown_s = 1 / max(0.01, weapon_stats.shoot_sfx_options.max_per_s)
            get_tree().create_timer(cooldown_s).connect("timeout", func(): sound_cooldown = false)
        haptic_feedback()
        start_cooldown_timer()
        return true
    else:
        return false

func haptic_feedback():
    match weapon_stats.haptic_feedback:
        E.HapticFeedback.ONE_SHOT:
            Controls.vibrate(0.1, 0.5, 0.0)
        E.HapticFeedback.ONE_SHOT_HEAVY:
            Controls.vibrate(0.2, 0.0, 1.0)
        E.HapticFeedback.AUTOMATIC:
            Controls.vibrate(0.02, 0.5, 1.0)
        E.HapticFeedback.CONTINUOUS:
            Controls.vibrate(0.02, 0.0, 0.5)
        _:
            push_warning("Unimplemented HapticFeedback with id [%d]" % weapon_stats.haptic_feedback)

func spawn_projectiles():
    var additional_speed_variation = 0.0
    var additional_spread_angle = 0.0
    for i in range(0, weapon_stats.bullets_per_shot):
        var new_bullet = WeaponService.create_projectile(get_weapon_name())
        new_bullet.bullet_stats = bullet_stats.duplicate(true)

        var speed_offset = randf_range(
            1 - bullet_stats.speed_variation - additional_speed_variation,
            1 + bullet_stats.speed_variation + additional_speed_variation
        )
        new_bullet.bullet_stats.speed = bullet_stats.speed * speed_offset
        new_bullet.global_position = %ShootingPoint.global_position
        new_bullet.global_scale = new_bullet.global_scale * (bullet_stats.size + randf_range(-bullet_stats.size_variation / 2, bullet_stats.size_variation / 2))

        var spread_angle_offset = deg_to_rad(
            randf_range(
                - weapon_stats.bullets_spread_angle_deg - additional_spread_angle,
                weapon_stats.bullets_spread_angle_deg + additional_spread_angle
            ) / 2
        )
        if ignore_spread:
            spread_angle_offset = 0

        new_bullet.global_rotation = %ShootingPoint.global_rotation + spread_angle_offset
        SceneManager.current_scene.add_child(new_bullet)

        # add variation to other bullets if multiple are launched per shot
        if bullet_stats.speed_variation == 0.0 and weapon_stats.bullets_per_shot > 1:
            additional_speed_variation = 0.3
        if weapon_stats.bullets_spread_angle_deg == 0.0 and weapon_stats.bullets_per_shot > 1:
            additional_spread_angle = 5.0

func start_cooldown_timer():
    %CooldownProgress.max_value = 1 / weapon_stats.shots_per_s
    %CooldownProgress.value = 1 / weapon_stats.shots_per_s
    %CooldownTimer.start(1 / weapon_stats.shots_per_s)
    cooling_down = true

func get_weapon_name() -> String:
    var scene_path = get_scene_file_path()
    var parts = scene_path.get_base_dir().split("/")
    return parts[-1]

func get_weapon_description() -> String:
    var weapon_name = get_weapon_name()
    var tr_key = "WEAPON_" + weapon_name.to_upper() + "_DESCRIPTION"
    var description = tr(tr_key)
    if description != tr_key:
        return description
    else:
        return ""
