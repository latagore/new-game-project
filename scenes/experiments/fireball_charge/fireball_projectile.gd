extends Area2D

var direction = Vector2.RIGHT
var speed = 400.0
var power = 1.0
var lifetime = 5.0
var has_impacted = false

@onready var sprite = $Sprite2D
@onready var particles = $GPUParticles2D
@onready var impact_particles = $ImpactParticles

func initialize(dir: Vector2, spd: float, pwr: float, scale_mult: float):
	direction = dir.normalized()
	speed = spd
	power = pwr
	
	# Disable collision briefly to avoid immediate hits at spawn
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Start small (anticipation)
	scale = Vector2(scale_mult * 0.5, scale_mult * 0.5)
	
	# Adjust particle intensity based on power
	particles.amount = int(lerpf(10.0, 30.0, (power - 1.0) / 2.0))
	
	# Color based on power
	var color = _get_power_color(power)
	sprite.modulate = color
	
	# Grow to full size with overshoot (exaggeration)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(scale_mult, scale_mult), 0.15)
	
	# Enable collision after a brief delay (let it move away from spawn point)
	await get_tree().create_timer(0.1).timeout
	if not has_impacted:
		$CollisionShape2D.set_deferred("disabled", false)

func _get_power_color(pwr: float) -> Color:
	# 1.0 = orange, 3.0 = bright white-yellow
	var t = (pwr - 1.0) / 2.0
	if t < 0.5:
		return Color(1, lerpf(0.5, 0.7, t * 2.0), 0)
	else:
		return Color(1, lerpf(0.7, 1.0, (t - 0.5) * 2.0), lerpf(0.0, 0.9, (t - 0.5) * 2.0))

func _process(delta):
	position += direction * speed * delta
	lifetime -= delta
	
	if lifetime <= 0:
		queue_free()
	
	# Rotate based on direction
	rotation = direction.angle()
	
	# Secondary action: Slight bobbing motion for organic feel
	var bob = sin(Time.get_ticks_msec() * 0.015) * 2.0
	sprite.position.y = bob

func _on_body_entered(body):
	if not has_impacted:
		_create_impact_effect()

func _on_area_entered(area):
	if not has_impacted:
		_create_impact_effect()

func _create_impact_effect():
	has_impacted = true
	
	# Disable collision immediately to prevent multiple hits
	$CollisionShape2D.set_deferred("disabled", true)
	set_process(false)  # Stop movement
	
	impact_particles.emitting = true
	impact_particles.amount = int(lerpf(20.0, 80.0, (power - 1.0) / 2.0))
	
	# Anticipation: Brief expand before explosion
	var anticipation = create_tween()
	anticipation.set_parallel(true)
	anticipation.tween_property(sprite, "scale", sprite.scale * 1.4, 0.05)
	anticipation.tween_property(sprite, "modulate:a", 0.8, 0.05)
	await anticipation.finished
	
	# Follow through: Explosion with exaggeration
	var explosion = create_tween()
	explosion.set_parallel(true)
	explosion.set_ease(Tween.EASE_OUT)
	explosion.set_trans(Tween.TRANS_CUBIC)
	explosion.tween_property(sprite, "scale", sprite.scale * 2.0, 0.15)
	explosion.tween_property(sprite, "modulate:a", 0.0, 0.15)
	
	# Reparent particles so they don't get deleted with the fireball
	impact_particles.reparent(get_parent())
	
	await explosion.finished
	
	# Now safe to delete the fireball
	queue_free()
	
	# Auto-cleanup particles after they finish
	var timer = Timer.new()
	impact_particles.add_child(timer)
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.timeout.connect(impact_particles.queue_free)
	timer.start()

