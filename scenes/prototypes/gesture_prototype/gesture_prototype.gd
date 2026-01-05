extends Node2D

## Gesture Clicking Prototype
## Draw shapes with right mouse button to cast spells
## WASD to move, shapes cast toward mouse position

@onready var player = $Player
@onready var gesture_recognizer = $GestureRecognizer
@onready var gesture_display = $CanvasLayer/GestureDisplay
@onready var spell_label = $CanvasLayer/SpellLabel
@onready var draw_line = $DrawLine

var current_points: Array[Vector2] = []

func _ready():
	gesture_recognizer.gesture_recognized.connect(_on_gesture_recognized)
	gesture_recognizer.gesture_failed.connect(_on_gesture_failed)
	gesture_recognizer.drawing_started.connect(_on_drawing_started)
	gesture_recognizer.drawing_updated.connect(_on_drawing_updated)

	spell_label.text = "Right-click drag to draw gestures"
	_setup_draw_line()

func _setup_draw_line():
	draw_line.width = 3.0
	draw_line.default_color = Color(1, 0.8, 0.2, 0.8)

func _on_drawing_started():
	current_points.clear()
	draw_line.clear_points()
	spell_label.text = "Drawing..."
	spell_label.modulate = Color.WHITE

func _on_drawing_updated(points: Array):
	draw_line.clear_points()
	for p in points:
		draw_line.add_point(p)

func _on_gesture_recognized(gesture_name: String, power: float):
	var spell = gesture_recognizer.get_gesture_spell(gesture_name)
	var complexity = gesture_recognizer.get_gesture_complexity(gesture_name)

	spell_label.text = "%s! (Power: %.0f%%)" % [spell.to_upper(), power * 100]
	spell_label.modulate = Color.GREEN

	# Cast the spell
	_cast_spell(spell, power)

	# Clear drawing after short delay
	await get_tree().create_timer(0.3).timeout
	draw_line.clear_points()

func _on_gesture_failed():
	spell_label.text = "Fizzle! Try again"
	spell_label.modulate = Color.RED

	await get_tree().create_timer(0.5).timeout
	draw_line.clear_points()
	spell_label.text = "Right-click drag to draw gestures"
	spell_label.modulate = Color.WHITE

func _cast_spell(spell_name: String, power: float):
	var target_pos = get_global_mouse_position()
	var direction = (target_pos - player.global_position).normalized()

	match spell_name:
		"magic_missile":
			_spawn_projectile("magic_missile", direction, power, Color.CYAN)
		"shield":
			_spawn_shield(power)
		"fire_arrow":
			_spawn_projectile("fire_arrow", direction, power, Color.ORANGE)
		"fireball":
			_spawn_projectile("fireball", direction, power, Color.RED)
		"meteor":
			_spawn_meteor(target_pos, power)

func _spawn_projectile(type: String, direction: Vector2, power: float, color: Color):
	# Simple projectile visualization
	var projectile = Area2D.new()
	var sprite = ColorRect.new()
	var size = lerpf(10, 30, power)
	sprite.size = Vector2(size, size)
	sprite.position = -sprite.size / 2
	sprite.color = color
	projectile.add_child(sprite)

	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = size / 2
	collision.shape = shape
	projectile.add_child(collision)

	projectile.collision_layer = 2
	projectile.collision_mask = 4

	add_child(projectile)
	projectile.global_position = player.global_position

	# Move projectile
	var speed = lerpf(300, 600, power)
	var tween = create_tween()
	tween.tween_property(projectile, "global_position",
		projectile.global_position + direction * 800, 800 / speed)
	tween.tween_callback(projectile.queue_free)

	# Connect to enemies
	projectile.area_entered.connect(func(area):
		if area.is_in_group("hurtbox"):
			var damage = lerpf(5, 20, power)
			if area.has_method("take_damage"):
				area.take_damage(damage)
			projectile.queue_free()
	)

func _spawn_shield(power: float):
	var shield = ColorRect.new()
	var size = lerpf(60, 100, power)
	shield.size = Vector2(size, size)
	shield.position = -shield.size / 2
	shield.color = Color(0.2, 0.5, 1.0, 0.5)

	player.add_child(shield)

	var duration = lerpf(1.0, 3.0, power)
	await get_tree().create_timer(duration).timeout
	shield.queue_free()

func _spawn_meteor(target_pos: Vector2, power: float):
	var meteor = ColorRect.new()
	var size = lerpf(40, 80, power)
	meteor.size = Vector2(size, size)
	meteor.position = -meteor.size / 2
	meteor.color = Color(1, 0.3, 0)

	add_child(meteor)
	meteor.global_position = target_pos + Vector2(0, -400)

	# Fall down
	var tween = create_tween()
	tween.tween_property(meteor, "global_position", target_pos, 0.5)
	tween.tween_callback(func():
		# Explosion effect - damage enemies in radius
		var radius = lerpf(80, 150, power)
		var damage = lerpf(20, 50, power)

		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy.global_position.distance_to(target_pos) < radius:
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)

		# Visual explosion
		meteor.color = Color.YELLOW
		meteor.size = Vector2(radius * 2, radius * 2)
		meteor.position = -meteor.size / 2

		await get_tree().create_timer(0.2).timeout
		meteor.queue_free()
	)

func _input(event):
	# Reset scene
	if event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()
