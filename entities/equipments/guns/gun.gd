extends EquipmentItem
class_name Gun

@export var fire_range = 200.0
@export var fire_cooldown_s = 1.0
@export var bullet_damage = 1.0
var flipped = false
var cooling_down = false

func _ready():
	%AutoFireRange.shape.radius = fire_range

func _process(_delta):
	%CooldownProgress.value = %CooldownTimer.time_left
	target_mouse()
	if Input.is_action_pressed("fire"):
		shoot_bullet()

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

func get_bullet():
	return preload("res://entities/projectiles/SimpleGunProjectile/SimpleGunProjectile.tscn")

func target_mouse():
	look_at(get_global_mouse_position())

func shoot_bullet():
	if !cooling_down:
		var new_bullet = get_bullet().instantiate().with_damage(bullet_damage)
		new_bullet.global_position = %ShootingPoint.global_position
		new_bullet.global_rotation = %ShootingPoint.global_rotation
		get_node("/root").get_node("./").add_child(new_bullet)
		%Sprite.play("firing")
		%ShootSound.play()
		start_cooldown_timer()

func start_cooldown_timer():
	%CooldownProgress.max_value = fire_cooldown_s
	%CooldownProgress.value = fire_cooldown_s
	%CooldownTimer.start(fire_cooldown_s)
	cooling_down = true

func _on_sprite_animation_finished():
	%Sprite.play("idle")

func _on_cooldown_timer_timeout():
	if cooling_down:
		if !Input.is_action_pressed("fire"):
			%Sprite.play("idle")
		cooling_down = false
