extends EquipmentItem
class_name Gun

@export var gun_stats: GunStats
@export var bullet_stats: BulletStats

var flipped = false
var cooling_down = false

func _enter_tree() -> void:
    if !gun_stats:
        push_warning("gun has no gun_stats defined, falling back to default")
        gun_stats = load("res://equipment/guns/_generics/stats/default_gun_stats.tres")
    if !bullet_stats:
        push_warning("gun has no bullet_stats defined, falling back to default")
        bullet_stats = load("res://equipment/guns/_generics/stats/default_bullet_stats.tres")

func _ready():
    if Input.get_connected_joypads().size() > 0:
        %Crosshair.show()

func _process(_delta):
    %CooldownProgress.value = %CooldownTimer.time_left
    move_target()
    if Input.is_action_pressed("fire"):
        shoot()

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
    %Crosshair.global_rotation = 0.0

func shoot():
    if !cooling_down:
        spawn_bullets()
        if gun_stats.eject_cartridges:
            eject_cartridge()
        %Sprite.play("firing")
        Sounds.shoot(gun_stats.bang_volume, gun_stats.bang_pitch_shift)
        %MuzzleFlash.play("flash")
        start_cooldown_timer()

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
    var shell = preload("res://equipment/guns/_generics/ammo_shell.tscn").instantiate()
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
        if !Input.is_action_pressed("fire"):
            %Sprite.play("idle")
        cooling_down = false
