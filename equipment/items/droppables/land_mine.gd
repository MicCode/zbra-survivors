extends CharacterBody2D
class_name LandMine

var time_to_set_up = 0.25
var time_to_explode = 0.5
var damage = 50.0
var explosion_radius = 200.0
var expansion_time = 0.15

var ready_to_explode = false
var triggered = false

var already_damaged_nodes = []

func _ready() -> void:
	modulate = Color.DARK_RED
	get_tree().create_timer(time_to_set_up).timeout.connect(func():
		modulate = Color.WHITE
		ready_to_explode = true
		Sounds.click()
	)

func _on_detection_area_body_entered(_body: Node2D) -> void:
	if ready_to_explode:
		trigger()

func _on_detection_area_area_entered(_area: Area2D) -> void:
	if ready_to_explode:
		trigger()

func trigger():
	if !triggered:
		triggered = true
		Sounds.toggle()
		get_tree().create_timer(time_to_explode).timeout.connect(explode)

func explode():
	GameService.shake_screen.emit(5.0)
	Sounds.explosion()
	var damage_radius = %DamageRadius.shape as CircleShape2D
	damage_radius.radius = 1.0
	%ExplosionPanel.size = Vector2(0, 0)
	%ExplosionPanel.position = Vector2(0, 0)
	%ExplosionPanel.show()
	get_tree().create_tween().tween_property(%Sprite2D, "modulate", Color.TRANSPARENT, expansion_time / 10)
	get_tree().create_tween().tween_property(%ExplosionPanel, "size", Vector2(explosion_radius * 4, explosion_radius * 4), expansion_time).finished.connect(func():
		%ExplosionPanel.hide()
	)
	get_tree().create_tween().tween_property(%ExplosionPanel, "position", Vector2(-explosion_radius * 2, -explosion_radius * 2), expansion_time)
	get_tree().create_tween().tween_property(damage_radius, "radius", explosion_radius, expansion_time).connect("finished", func():
		queue_free()
	)

func _on_damage_area_area_entered(_area: Area2D) -> void:
	if triggered:
		give_damage()

func _on_damage_area_body_entered(_body: Node2D) -> void:
	if triggered:
		give_damage()

func give_damage():
	for overlapping_body in %DamageArea.get_overlapping_bodies():
		var body_id = (overlapping_body as Node2D).get_instance_id()
		if !already_damaged_nodes.has(body_id):
			already_damaged_nodes.append(body_id)
			if overlapping_body is Ennemy:
				(overlapping_body as Ennemy).take_damage(damage)
			elif overlapping_body is EnvTree:
				(overlapping_body as EnvTree).explode()
			elif overlapping_body is LandMine:
				(overlapping_body as LandMine).explode()
