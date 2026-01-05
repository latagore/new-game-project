extends Node2D

## Typing + Click Prototype
## Type spell names to prepare, click to cast
## Short words = fast/weak, long words = slow/powerful

@onready var player = $Player
@onready var typing_input = $TypingSpellInput
@onready var buffer_label = $CanvasLayer/BufferLabel
@onready var spell_label = $CanvasLayer/SpellLabel
@onready var hint_label = $CanvasLayer/HintLabel

func _ready():
	typing_input.typing_started.connect(_on_typing_started)
	typing_input.typing_updated.connect(_on_typing_updated)
	typing_input.spell_ready.connect(_on_spell_ready)
	typing_input.spell_cast.connect(_on_spell_cast)
	typing_input.typing_failed.connect(_on_typing_failed)
	typing_input.typing_cleared.connect(_on_typing_cleared)

	buffer_label.text = ""
	spell_label.text = "Type to cast spells"
	_update_hint("")

func _on_typing_started():
	spell_label.text = "Typing..."
	spell_label.modulate = Color.YELLOW

func _on_typing_updated(buffer: String, is_valid: bool):
	buffer_label.text = buffer.to_upper()

	if is_valid:
		buffer_label.modulate = Color.WHITE
	else:
		buffer_label.modulate = Color.RED

	_update_hint(buffer)

func _on_spell_ready(spell_name: String):
	spell_label.text = "Ready: %s (Click to cast!)" % spell_name.to_upper().replace("_", " ")
	spell_label.modulate = Color.GREEN

	# Flash the buffer
	var tween = create_tween()
	tween.tween_property(buffer_label, "modulate", Color.GREEN, 0.1)
	tween.tween_property(buffer_label, "modulate", Color.WHITE, 0.1)

func _on_spell_cast(spell_name: String, power: float):
	spell_label.text = "Cast: %s!" % spell_name.to_upper().replace("_", " ")
	spell_label.modulate = Color.CYAN

	# Cast the spell
	var target_pos = get_global_mouse_position()
	_cast_spell(spell_name, power, target_pos)

	await get_tree().create_timer(0.5).timeout
	spell_label.text = "Type to cast spells"
	spell_label.modulate = Color.WHITE

func _on_typing_failed():
	buffer_label.text = "???"
	buffer_label.modulate = Color.RED
	spell_label.text = "Invalid spell!"
	spell_label.modulate = Color.RED

	await get_tree().create_timer(0.3).timeout
	buffer_label.text = ""
	spell_label.text = "Type to cast spells"
	spell_label.modulate = Color.WHITE

func _on_typing_cleared():
	buffer_label.text = ""
	hint_label.text = ""

func _update_hint(buffer: String):
	if buffer.length() == 0:
		hint_label.text = "f/i/l (quick) | fire/ice/bolt (medium) | firestorm/blizzard/thunder (power)"
		return

	var matching = typing_input.get_spells_with_prefix(buffer)
	if matching.size() > 0:
		var hints = []
		for spell in matching.slice(0, 5):  # Show max 5
			hints.append(spell)
		hint_label.text = "Options: " + ", ".join(hints)
	else:
		hint_label.text = ""

func _cast_spell(spell_name: String, power: float, target_pos: Vector2):
	var direction = (target_pos - player.global_position).normalized()

	match spell_name:
		# Fire spells
		"spark":
			_spawn_projectile(direction, power, Color(1, 0.5, 0), 8)
		"fireball":
			_spawn_projectile(direction, power, Color(1, 0.3, 0), 20)
		"double_spark":
			_spawn_projectile(direction.rotated(-0.1), power, Color(1, 0.5, 0), 10)
			_spawn_projectile(direction.rotated(0.1), power, Color(1, 0.5, 0), 10)
		"firestorm":
			_spawn_aoe(target_pos, power, Color(1, 0.2, 0), 150)

		# Ice spells
		"ice_shard":
			_spawn_projectile(direction, power, Color(0.5, 0.8, 1), 8)
		"ice_lance":
			_spawn_projectile(direction, power, Color(0.3, 0.6, 1), 25)
		"ice_barrage":
			for i in range(3):
				await get_tree().create_timer(0.1).timeout
				var spread = (i - 1) * 0.15
				_spawn_projectile(direction.rotated(spread), power, Color(0.5, 0.8, 1), 12)
		"blizzard":
			_spawn_aoe(target_pos, power, Color(0.4, 0.7, 1), 120)

		# Lightning spells
		"zap":
			_spawn_lightning(target_pos, power * 0.5)
		"lightning_bolt":
			_spawn_lightning(target_pos, power)
		"thunderstorm":
			for i in range(5):
				await get_tree().create_timer(0.15).timeout
				var offset = Vector2(randf_range(-80, 80), randf_range(-80, 80))
				_spawn_lightning(target_pos + offset, power * 0.7)

func _spawn_projectile(direction: Vector2, power: float, color: Color, base_size: float):
	var projectile = Area2D.new()
	var sprite = ColorRect.new()
	var size = base_size * (1 + power * 0.5)
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

	var speed = lerpf(400, 700, power)
	var tween = create_tween()
	tween.tween_property(projectile, "global_position",
		projectile.global_position + direction * 900, 900 / speed)
	tween.tween_callback(projectile.queue_free)

	projectile.area_entered.connect(func(area):
		if area.is_in_group("hurtbox"):
			var damage = lerpf(5, 30, power)
			if area.has_method("take_damage"):
				area.take_damage(damage)
			projectile.queue_free()
	)

func _spawn_lightning(target_pos: Vector2, power: float):
	var line = Line2D.new()
	line.width = lerpf(2, 6, power)
	line.default_color = Color(0.9, 0.9, 1.0)

	# Create jagged lightning path
	var start = player.global_position
	var segments = 8
	var prev_point = start
	line.add_point(start)

	for i in range(1, segments):
		var t = float(i) / float(segments)
		var base_point = start.lerp(target_pos, t)
		var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20)) * (1 - t)
		line.add_point(base_point + offset)

	line.add_point(target_pos)
	add_child(line)

	# Damage at target
	var damage = lerpf(10, 35, power)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.global_position.distance_to(target_pos) < 40:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)

	await get_tree().create_timer(0.15).timeout
	line.queue_free()

func _spawn_aoe(center: Vector2, power: float, color: Color, base_radius: float):
	var aoe = ColorRect.new()
	var radius = base_radius * (1 + power * 0.3)
	aoe.size = Vector2(radius * 2, radius * 2)
	aoe.position = -aoe.size / 2
	aoe.color = Color(color.r, color.g, color.b, 0.6)

	add_child(aoe)
	aoe.global_position = center

	# Expand effect
	aoe.scale = Vector2(0.1, 0.1)
	var tween = create_tween()
	tween.tween_property(aoe, "scale", Vector2(1, 1), 0.2)

	# Damage enemies in radius
	var damage = lerpf(20, 50, power)
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.global_position.distance_to(center) < radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)

	await get_tree().create_timer(0.5).timeout
	tween = create_tween()
	tween.tween_property(aoe, "modulate:a", 0.0, 0.3)
	tween.tween_callback(aoe.queue_free)

func _input(event):
	if event.is_action_pressed("ui_cancel") and not typing_input.is_spell_ready():
		get_tree().reload_current_scene()
