extends EquipmentItem
class_name Gun

@export var gun_stats: GunStats
@export var bullet_stats: BulletStats

var flipped = false
var cooling_down = false
var sound_cooldown = false
var draw_aim_line = true

var initial_x_position: float
var recoil_distance: float = 0.0
var recoil_decay: float = 10.0

func _enter_tree() -> void:
    if !gun_stats:
        push_warning("gun has no gun_stats defined, falling back to default")
        gun_stats = load("res://items/guns/_generics/stats/default_gun_stats.tres")
    if !bullet_stats:
        push_warning("gun has no bullet_stats defined, falling back to default")
        bullet_stats = load("res://items/guns/_generics/stats/default_bullet_stats.tres")

func _ready():
    initial_x_position = %Sprite.position.x
    var guides = %AimGuides as AimGuides
    guides.set_dispersion_angle(gun_stats.bullets_spread_angle_deg)
    if gun_stats.has_laser_dot:
        %RedDot.show()
        guides.hide()
    else:
        %RedDot.hide()
        guides.show()

func _process(_delta):
    %CooldownProgress.value = %CooldownTimer.time_left
    if Controls.is_pressed(Controls.PlayerAction.SHOOT):
        shoot()
    if recoil_distance > 0.01:
        %Sprite.position.x = initial_x_position - recoil_distance
        recoil_distance = lerp(recoil_distance, 0.0, _delta * recoil_decay)
    else:
        %Sprite.position.x = initial_x_position
    move_target()
        

func _physics_process(_delta):
    if self.global_rotation_degrees > 90 || self.global_rotation_degrees < -90:
        if !flipped:
            flipped = true
            %Sprite.scale = Vector2(1, -1)
    else:
        if flipped:
            flipped = false
            %Sprite.scale = Vector2(1, 1)

func move_target():
    var joypads = Input.get_connected_joypads()
    if joypads.size() > 0:
        var joystick_direction = Input.get_vector("look_left", "look_right", "look_up", "look_down")
        var look_point = global_position + joystick_direction
        look_at(look_point)
    else:
        look_at(get_global_mouse_position())

func shoot():
    if !cooling_down:
        spawn_bullets()
        recoil()
        if gun_stats.eject_cartridges:
            eject_cartridge()
        %Sprite.play("firing")
        if !sound_cooldown:
            Sounds.shoot(gun_stats.shoot_sfx_options, gun_stats.shoot_sound)
            sound_cooldown = true
            var cooldown_s = 1 / max(0.01, gun_stats.shoot_sfx_options.max_per_s)
            get_tree().create_timer(cooldown_s).connect("timeout", func(): sound_cooldown = false)
        %MuzzleFlash.play("flash")
        start_cooldown_timer()

func recoil():
    recoil_distance = gun_stats.recoil_distance

func spawn_bullets():
    for i in range(0, gun_stats.bullets_per_shot):
        var new_bullet = GunService.create_projectile(gun_stats.name)

        var speed_offset = randf_range(
            1 - bullet_stats.speed_variation,
            1 + bullet_stats.speed_variation
        )
        new_bullet.bullet_stats.speed = bullet_stats.speed * speed_offset
        new_bullet.global_position = %ShootingPoint.global_position
        new_bullet.global_scale = new_bullet.global_scale * (bullet_stats.size + randf_range(-bullet_stats.size_variation / 2, bullet_stats.size_variation / 2))

        var spread_angle_offset = deg_to_rad(
            randf_range(
                - gun_stats.bullets_spread_angle_deg,
                gun_stats.bullets_spread_angle_deg
            ) / 2
        )
        new_bullet.global_rotation = %ShootingPoint.global_rotation + spread_angle_offset
        SceneManager.current_scene.add_child(new_bullet)

func eject_cartridge():
    # TODO make shell configurable to vary between guns
    var shell = preload("res://items/guns/_generics/ammo_shell.tscn").instantiate()
    shell.global_position = %ShellEjectPoint.global_position
    if flipped:
        shell.scale = Vector2(-1, 1)
    SceneManager.current_scene.add_child(shell)
    shell.start_animation()

func start_cooldown_timer():
    %CooldownProgress.max_value = 1 / gun_stats.shots_per_s
    %CooldownProgress.value = 1 / gun_stats.shots_per_s
    %CooldownTimer.start(1 / gun_stats.shots_per_s)
    cooling_down = true

func _on_sprite_animation_finished():
    %Sprite.play("idle")

func _on_cooldown_timer_timeout():
    if cooling_down:
        if !Controls.is_pressed(Controls.PlayerAction.SHOOT):
            %Sprite.play("idle")
        cooling_down = false
