extends Area2D

var health = 100.0
var max_health = 100.0
var is_highlighted = false

@onready var sprite = $Sprite2D
@onready var health_bar = $HealthBar
@onready var health_fill = $HealthBar/Fill
@onready var damage_label = $DamageLabel

func _ready():
	_update_health_bar()

func set_highlighted(highlight: bool):
	is_highlighted = highlight
	if highlight:
		sprite.modulate = Color(1.0, 1.0, 1.0)
	else:
		sprite.modulate = Color(1.0, 0.5, 0.5)

func take_damage(amount: float):
	health = max(0, health - amount)
	_update_health_bar()
	_show_damage(amount)
	
	# Squash & stretch on impact (exaggeration based on damage)
	var impact_force = clampf(amount / 100.0, 0.3, 1.0)
	var squash_tween = create_tween()
	squash_tween.set_parallel(true)
	squash_tween.set_ease(Tween.EASE_OUT)
	squash_tween.set_trans(Tween.TRANS_ELASTIC)
	
	# Squash on hit, then bounce back
	squash_tween.tween_property(self, "scale:x", 1.0 - (impact_force * 0.3), 0.08)
	squash_tween.tween_property(self, "scale:y", 1.0 + (impact_force * 0.3), 0.08)
	squash_tween.chain().tween_property(self, "scale", Vector2.ONE, 0.3)
	
	# Flash white when hit (anticipation + follow through)
	var flash_tween = create_tween()
	flash_tween.set_ease(Tween.EASE_OUT)
	var target_color = Color(1.0, 1.0, 1.0) if is_highlighted else Color(1.0, 0.5, 0.5)
	# Quick flash in, slower fade out
	flash_tween.tween_property(sprite, "modulate", Color.WHITE, 0.04)
	flash_tween.tween_property(sprite, "modulate", target_color, 0.15)
	
	if health <= 0:
		_destroy()

func _update_health_bar():
	var health_percent = health / max_health
	health_fill.scale.x = health_percent
	
	# Color based on health
	if health_percent > 0.6:
		health_fill.color = Color.GREEN
	elif health_percent > 0.3:
		health_fill.color = Color.YELLOW
	else:
		health_fill.color = Color.RED

func _show_damage(amount: float):
	damage_label.text = "-%.0f" % amount
	damage_label.modulate.a = 1.0
	damage_label.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	
	# Pop in with overshoot (anticipation)
	tween.tween_property(damage_label, "scale", Vector2.ONE * 1.3, 0.1).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_property(damage_label, "scale", Vector2.ONE, 0.1)
	
	# Float up with ease out (follow through)
	var move_tween = create_tween()
	move_tween.set_ease(Tween.EASE_OUT)
	move_tween.set_trans(Tween.TRANS_CUBIC)
	move_tween.tween_property(damage_label, "position:y", damage_label.position.y - 40, 0.6)
	move_tween.parallel().tween_property(damage_label, "modulate:a", 0.0, 0.6)
	
	await move_tween.finished
	damage_label.position.y += 40

func _destroy():
	# Exaggerated explosion with squash & stretch
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	# Expand and fade (exaggeration)
	tween.tween_property(self, "scale", Vector2(2.0, 2.0), 0.25)
	tween.tween_property(self, "modulate:a", 0.0, 0.25)
	
	# Rotate for extra impact
	tween.tween_property(self, "rotation", randf_range(-0.5, 0.5), 0.25)
	
	await tween.finished
	
	# Hide and disable collision
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Wait 1 second and respawn
	await get_tree().create_timer(1.0).timeout
	_respawn()

func _respawn():
	# Reset health
	health = max_health
	_update_health_bar()
	
	# Reset visuals
	sprite.modulate = Color(1, 0.5, 0.5)
	scale = Vector2.ZERO
	modulate.a = 1.0
	rotation = 0.0
	
	# Re-enable
	visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	
	# Pop in with anticipation (bounce in from small)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)

func _on_area_entered(area):
	# Check if it's a fireball
	if area.name.begins_with("Fireball"):
		var damage = area.power * 33.0  # Base damage scaled by power
		take_damage(damage)

