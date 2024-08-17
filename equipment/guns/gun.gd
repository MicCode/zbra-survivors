extends EquipmentItem
class_name Gun

var flipped = false
var cooling_down = false
var gun_info: GunInfo

func _ready():
	gun_info = EquipmentService.get_gun_info(self)
	%AutoFireRange.shape.radius = gun_info.fire_range

func _process(_delta):
	%CooldownProgress.value = %CooldownTimer.time_left
	target_mouse()
	if Input.is_action_pressed("fire"):
		shoot()

func _physics_process(_delta):
	if self.global_rotation_degrees > 90 || self.global_rotation_degrees < -90:
		if !flipped:
			flipped = true
			%ShootingPoint.translate(Vector2(0, 6))
			%CanvasGroup.translate(Vector2(0, 28))
		%Sprite.set_flip_v(true)
	else:
		if flipped:
			flipped = false
			%ShootingPoint.translate(Vector2(0, -6))
			%CanvasGroup.translate(Vector2(0, -28))
		%Sprite.set_flip_v(false)

func target_mouse():
	look_at(get_global_mouse_position())

func shoot():
	if !cooling_down:
		spawn_bullets()
		%Sprite.play("firing")
		%ShootSound.pitch_scale = randf_range(0.9, 1.05) + gun_info.bang_pitch_shift
		%ShootSound.play()
		start_cooldown_timer()

func spawn_bullets():
	for i in range(0, gun_info.bullets_per_shot):
		var new_bullet = EquipmentService.get_gun_projectile(self).with_damage(gun_info.bullet_damage)

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

		get_node("/root").get_node("./").add_child(new_bullet)

func start_cooldown_timer():
	%CooldownProgress.max_value = gun_info.fire_cooldown_s
	%CooldownProgress.value = gun_info.fire_cooldown_s
	%CooldownTimer.start(gun_info.fire_cooldown_s)
	cooling_down = true

func _on_sprite_animation_finished():
	%Sprite.play("idle")

func _on_cooldown_timer_timeout():
	if cooling_down:
		if !Input.is_action_pressed("fire"):
			%Sprite.play("idle")
		cooling_down = false
