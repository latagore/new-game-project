extends Node2D

## Rhythm Clicking Prototype
## Click to the beat to cast spells
## Press 1-4 to start a pattern, then click to the rhythm

@onready var player = $Player
@onready var rhythm_pattern = $RhythmPattern
@onready var spell_label = $CanvasLayer/SpellLabel
@onready var beat_display = $CanvasLayer/BeatDisplay
@onready var accuracy_label = $CanvasLayer/AccuracyLabel

var pattern_names = ["spark", "fireball", "lightning", "meteor"]
var beat_indicators: Array[ColorRect] = []
var pattern_start_time: float = 0.0

func _ready():
	rhythm_pattern.pattern_started.connect(_on_pattern_started)
	rhythm_pattern.beat_hit.connect(_on_beat_hit)
	rhythm_pattern.beat_missed.connect(_on_beat_missed)
	rhythm_pattern.pattern_complete.connect(_on_pattern_complete)
	rhythm_pattern.pattern_failed.connect(_on_pattern_failed)

	spell_label.text = "Press 1-4 to start a pattern"
	accuracy_label.text = ""

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		# Number keys to start patterns
		if event.keycode >= KEY_1 and event.keycode <= KEY_4:
			var pattern_idx = event.keycode - KEY_1
			if pattern_idx < pattern_names.size():
				_start_pattern(pattern_names[pattern_idx])

		# ESC to cancel
		if event.keycode == KEY_ESCAPE:
			if rhythm_pattern.is_pattern_active():
				rhythm_pattern.cancel_pattern()
			else:
				get_tree().reload_current_scene()

func _start_pattern(pattern_name: String):
	if rhythm_pattern.is_pattern_active():
		return

	rhythm_pattern.start_pattern(pattern_name)

func _on_pattern_started(pattern_name: String):
	spell_label.text = "Casting: %s - Click to the beat!" % pattern_name.to_upper()
	spell_label.modulate = Color.YELLOW
	pattern_start_time = Time.get_ticks_msec() / 1000.0

	_create_beat_indicators(pattern_name)

func _create_beat_indicators(pattern_name: String):
	# Clear old indicators
	for indicator in beat_indicators:
		indicator.queue_free()
	beat_indicators.clear()

	var beats = rhythm_pattern.get_pattern_beats(pattern_name)
	var total_beats = beats.size()

	# Create indicator for each beat
	for i in range(total_beats):
		var indicator = ColorRect.new()
		indicator.size = Vector2(30, 30)
		indicator.color = Color(0.3, 0.3, 0.3)

		# Position horizontally
		var x_pos = 100 + i * 50
		indicator.position = Vector2(x_pos, 100)

		beat_display.add_child(indicator)
		beat_indicators.append(indicator)

func _on_beat_hit(accuracy: float):
	var beat_idx = rhythm_pattern.get_current_beat_index() - 1

	if beat_idx >= 0 and beat_idx < beat_indicators.size():
		var indicator = beat_indicators[beat_idx]

		# Color based on accuracy
		if accuracy >= 1.0:
			indicator.color = Color.GREEN
			accuracy_label.text = "PERFECT!"
			accuracy_label.modulate = Color.GREEN
		elif accuracy >= 0.8:
			indicator.color = Color.YELLOW
			accuracy_label.text = "Good!"
			accuracy_label.modulate = Color.YELLOW
		else:
			indicator.color = Color.ORANGE
			accuracy_label.text = "OK"
			accuracy_label.modulate = Color.ORANGE

		# Flash effect
		var tween = create_tween()
		tween.tween_property(indicator, "scale", Vector2(1.3, 1.3), 0.05)
		tween.tween_property(indicator, "scale", Vector2(1.0, 1.0), 0.1)

func _on_beat_missed():
	accuracy_label.text = "MISS!"
	accuracy_label.modulate = Color.RED

func _on_pattern_complete(pattern_name: String, score: float):
	var spell = rhythm_pattern.get_pattern_spell(pattern_name)

	spell_label.text = "%s Complete! Score: %.0f%%" % [spell.to_upper(), score * 100]
	spell_label.modulate = Color.GREEN

	# Cast the spell
	_cast_spell(spell, score)

	# Reset after delay
	await get_tree().create_timer(1.0).timeout
	_clear_indicators()
	spell_label.text = "Press 1-4 to start a pattern"
	spell_label.modulate = Color.WHITE
	accuracy_label.text = ""

func _on_pattern_failed(pattern_name: String):
	spell_label.text = "Pattern Failed!"
	spell_label.modulate = Color.RED

	# Mark remaining beats as failed
	for i in range(rhythm_pattern.get_current_beat_index(), beat_indicators.size()):
		if i < beat_indicators.size():
			beat_indicators[i].color = Color.RED

	await get_tree().create_timer(1.0).timeout
	_clear_indicators()
	spell_label.text = "Press 1-4 to start a pattern"
	spell_label.modulate = Color.WHITE
	accuracy_label.text = ""

func _clear_indicators():
	for indicator in beat_indicators:
		indicator.queue_free()
	beat_indicators.clear()

func _cast_spell(spell_name: String, power: float):
	var target_pos = get_global_mouse_position()
	var direction = (target_pos - player.global_position).normalized()

	match spell_name:
		"spark":
			_spawn_projectile(direction, power, Color.CYAN, 10)
		"fireball":
			_spawn_projectile(direction, power, Color.ORANGE, 20)
		"lightning":
			_spawn_lightning(target_pos, power)
		"meteor":
			_spawn_meteor(target_pos, power)

func _spawn_projectile(direction: Vector2, power: float, color: Color, base_size: float):
	var projectile = Area2D.new()
	var sprite = ColorRect.new()
	var size = lerpf(base_size, base_size * 2, power)
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

	var speed = lerpf(300, 600, power)
	var tween = create_tween()
	tween.tween_property(projectile, "global_position",
		projectile.global_position + direction * 800, 800 / speed)
	tween.tween_callback(projectile.queue_free)

	projectile.area_entered.connect(func(area):
		if area.is_in_group("hurtbox"):
			var damage = lerpf(5, 25, power)
			if area.has_method("take_damage"):
				area.take_damage(damage)
			projectile.queue_free()
	)

func _spawn_lightning(target_pos: Vector2, power: float):
	# Instant line to target
	var line = Line2D.new()
	line.width = lerpf(2, 8, power)
	line.default_color = Color(0.8, 0.8, 1.0)
	line.add_point(player.global_position)
	line.add_point(target_pos)
	add_child(line)

	# Damage at target
	var damage = lerpf(15, 40, power)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.global_position.distance_to(target_pos) < 50:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)

	await get_tree().create_timer(0.2).timeout
	line.queue_free()

func _spawn_meteor(target_pos: Vector2, power: float):
	var meteor = ColorRect.new()
	var size = lerpf(50, 100, power)
	meteor.size = Vector2(size, size)
	meteor.position = -meteor.size / 2
	meteor.color = Color(1, 0.3, 0)

	add_child(meteor)
	meteor.global_position = target_pos + Vector2(0, -400)

	var tween = create_tween()
	tween.tween_property(meteor, "global_position", target_pos, 0.5)
	tween.tween_callback(func():
		var radius = lerpf(100, 200, power)
		var damage = lerpf(30, 60, power)

		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy.global_position.distance_to(target_pos) < radius:
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)

		meteor.color = Color.YELLOW
		meteor.size = Vector2(radius * 2, radius * 2)
		meteor.position = -meteor.size / 2

		await get_tree().create_timer(0.2).timeout
		meteor.queue_free()
	)
