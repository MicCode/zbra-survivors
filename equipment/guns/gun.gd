extends EquipmentItem
class_name Gun

@export var gun_name: String = "gun"

var flipped = false
var cooling_down = false
var gun_info: GunInfo

func _ready():
	gun_info = GunService.get_info(gun_name)
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
		if gun_info.eject_cartridges:
			eject_cartridge()
		%Sprite.play("firing")
		%ShootSound.pitch_scale = randf_range(0.9, 1.05) + gun_info.bang_pitch_shift
		%ShootSound.play()
		%MuzzleFlash.play("flash")
		start_cooldown_timer()

func spawn_bullets():
	for i in range(0, gun_info.bullets_per_shot):
		var new_bullet = GunService.create_projectile(gun_name).from(gun_info)

		var speed_offset = randf_range(
			1 - gun_info.bullets_speed_variability,
			1 + gun_info.bullets_speed_variability
		)
		new_bullet.speed = gun_info.bullet_speed * speed_offset
		new_bullet.global_position = %ShootingPoint.global_position

		var spread_angle_offset = deg_to_rad(
			randf_range(
				-gun_info.bullets_spread_angle_deg,
				gun_info.bullets_spread_angle_deg
			) / 2
		)
		new_bullet.global_rotation = %ShootingPoint.global_rotation + spread_angle_offset
		SceneManager.current_scene.add_child(new_bullet)
		
func eject_cartridge():
	# TODO make shell configurable to vary between guns
	var shell = preload("res://equipment/guns/ammo_shell.tscn").instantiate()
	shell.global_position = %ShellEjectPoint.global_position
	if flipped:
		shell.scale = Vector2(-1, 1)
	SceneManager.current_scene.add_child(shell)
	shell.start_animation()

func start_cooldown_timer():
	%CooldownProgress.max_value = 1 / gun_info.shots_per_s
	%CooldownProgress.value = 1 / gun_info.shots_per_s
	%CooldownTimer.start(1 / gun_info.shots_per_s)
	cooling_down = true

func _on_sprite_animation_finished():
	%Sprite.play("idle")

func _on_cooldown_timer_timeout():
	if cooling_down:
		if !Input.is_action_pressed("fire"):
			%Sprite.play("idle")
		cooling_down = false
