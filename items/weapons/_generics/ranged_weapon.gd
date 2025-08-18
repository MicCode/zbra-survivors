extends Weapon
class_name RangedWeapon

var draw_aim_line = true
var recoil_distance: float = 0.0
var recoil_decay: float = 10.0

func update_from_stats():
    super.update_from_stats()

    var guides = %AimGuides as AimGuides
    guides.set_dispersion_angle(weapon_stats.bullets_spread_angle_deg)
    if weapon_stats.has_laser_dot:
        %RedDot.show()
        guides.hide()
    else:
        %RedDot.hide()
        guides.show()


func _process(_delta):
    super._process(_delta)
    if recoil_distance > 0.01:
        %Sprite.position.x = initial_x_position - recoil_distance
        recoil_distance = lerp(recoil_distance, 0.0, _delta * recoil_decay)
    else:
        %Sprite.position.x = initial_x_position


func _physics_process(_delta):
    if self.global_rotation_degrees > 90 || self.global_rotation_degrees < -90:
        if !flipped:
            flipped = true
            %Sprite.scale = Vector2(1, -1)
    else:
        if flipped:
            flipped = false
            %Sprite.scale = Vector2(1, 1)

func shoot() -> bool:
    var shot_fired = super.shoot()
    if shot_fired:
        recoil()
        if weapon_stats.eject_cartridges:
            eject_cartridge()
        if weapon_stats.show_muzzle_flash:
            %MuzzleFlash.play("flash")
    return shot_fired

func recoil():
    recoil_distance = weapon_stats.recoil_distance

func eject_cartridge():
    # TODO make shell configurable to vary between weapons
    var shell = preload("res://items/weapons/_generics/ammo_shell.tscn").instantiate()
    shell.global_position = %ShellEjectPoint.global_position
    if flipped:
        shell.scale = Vector2(-1, 1)
    SceneManager.current_scene.add_child(shell)
    shell.start_animation()
