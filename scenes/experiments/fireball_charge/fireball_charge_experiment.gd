extends Node2D

const MAX_CHARGE_TIME = 3.0
const MIN_SCALE = 0.3
const MAX_SCALE = 2.5
const MIN_SPEED = 300.0
const MAX_SPEED = 800.0
const FLASH_THRESHOLD = 0.95  # Flash at 95% charge

var is_charging = false
var charge_time = 0.0
var has_flashed = false
var charge_start_position = Vector2.ZERO

@onready var charge_indicator = $ChargeIndicator
@onready var flash_overlay = $CanvasLayer/FlashOverlay
@onready var launch_particles = $LaunchParticles
@onready var charge_label = $CanvasLayer/ChargeLabel

# Fireball scene (we'll create a simple one)
var fireball_scene = preload("res://scenes/experiments/fireball_charge/fireball_projectile.tscn")

func _ready():
	flash_overlay.modulate = Color(1, 1, 1, 0)
	charge_indicator.scale = Vector2(MIN_SCALE, MIN_SCALE)
	charge_indicator.modulate = Color(1, 0.5, 0, 0.3)  # Orange, semi-transparent

func _process(delta):
	# Handle mouse input for charging
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not is_charging:
			_start_charging()
		_update_charge(delta)
	elif is_charging:
		_launch_fireball()
	
	# Smoothly interpolate charge indicator position to mouse (less aggressive)
	if is_charging:
		var target_pos = get_global_mouse_position()
		var smooth_speed = 15.0  # Lower = more lag, higher = more responsive
		charge_indicator.global_position = charge_indicator.global_position.lerp(target_pos, smooth_speed * delta)

func _start_charging():
	is_charging = true
	charge_time = 0.0
	has_flashed = false
	charge_indicator.visible = true
	charge_indicator.scale = Vector2.ZERO
	charge_start_position = get_global_mouse_position()
	charge_indicator.global_position = charge_start_position
	
	# Anticipation: Pop in with squash & stretch
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)  # Overshoot for emphasis
	tween.tween_property(charge_indicator, "scale", Vector2(MIN_SCALE, MIN_SCALE), 0.15)

func _update_charge(delta):
	charge_time = min(charge_time + delta, MAX_CHARGE_TIME)
	var charge_percent = charge_time / MAX_CHARGE_TIME
	
	# Ease in/out for scale (not linear growth)
	var eased_percent = ease(charge_percent, -0.5)  # Exponential ease for building energy
	var current_scale = lerpf(MIN_SCALE, MAX_SCALE, eased_percent)
	
	# Squash & stretch: slightly oval when growing fast
	var stretch_factor = 1.0
	if charge_percent < 0.3:
		# Early charge: vertical stretch (building up)
		stretch_factor = 1.0 + (0.3 - charge_percent) * 0.3
		charge_indicator.scale = Vector2(current_scale / stretch_factor, current_scale * stretch_factor)
	else:
		charge_indicator.scale = Vector2(current_scale, current_scale)
	
	# Color shift: orange -> red -> white (hot)
	var color: Color
	if charge_percent < 0.5:
		# Orange to red
		color = Color(1, lerpf(0.5, 0.3, charge_percent * 2.0), 0)
	else:
		# Red to bright yellow-white
		var t = (charge_percent - 0.5) * 2.0
		color = Color(1, lerpf(0.3, 1.0, t), lerpf(0.0, 0.8, t))
	
	charge_indicator.modulate = Color(color.r, color.g, color.b, lerpf(0.5, 1.0, charge_percent))
	
	# Pulsing effect at high charge (secondary action)
	if charge_percent > 0.7:
		# Faster, more exaggerated pulse as we approach max
		var pulse_speed = lerpf(0.01, 0.02, (charge_percent - 0.7) / 0.3)
		var pulse_intensity = lerpf(0.08, 0.15, (charge_percent - 0.7) / 0.3)
		var pulse = sin(Time.get_ticks_msec() * pulse_speed) * pulse_intensity + 1.0
		charge_indicator.scale *= pulse
	
	# Screen flash at max charge
	if charge_percent >= FLASH_THRESHOLD and not has_flashed:
		_trigger_max_charge_flash()
		has_flashed = true
	
	# Update label
	charge_label.text = "Charge: %.1f%% (Hold: %.2fs)\nPower: x%.1f" % [
		charge_percent * 100.0,
		charge_time,
		lerpf(1.0, 3.0, charge_percent)
	]

func _trigger_max_charge_flash():
	# Screen flash with anticipation and follow through
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Quick flash in, slower fade out (follow through)
	tween.tween_property(flash_overlay, "modulate:a", 0.6, 0.05)
	tween.tween_property(flash_overlay, "modulate:a", 0.0, 0.3)
	
	# Squash & stretch on charge indicator at max
	var shake_tween = create_tween()
	shake_tween.tween_property(charge_indicator, "scale", charge_indicator.scale * 1.2, 0.05)
	shake_tween.tween_property(charge_indicator, "scale", charge_indicator.scale, 0.1)

func _launch_fireball():
	# Reset state immediately to prevent multiple launches
	var charge_percent = charge_time / MAX_CHARGE_TIME
	is_charging = false
	
	# Anticipation: Squash before launch
	var anticipation_tween = create_tween()
	anticipation_tween.set_parallel(true)
	anticipation_tween.tween_property(charge_indicator, "scale", charge_indicator.scale * 0.7, 0.08)
	# Squash horizontally, stretch vertically (winding up)
	anticipation_tween.tween_property(charge_indicator, "scale:x", charge_indicator.scale.x * 0.6, 0.08)
	await anticipation_tween.finished
	
	# Calculate launch direction from charge position to mouse
	var launch_pos = charge_indicator.global_position
	var target_pos = get_global_mouse_position()
	var launch_direction = launch_pos.direction_to(target_pos)
	
	# If no charge (instant click), default to right
	if charge_time < 0.1:
		launch_direction = Vector2.RIGHT
	
	# Spawn fireball
	var fireball = fireball_scene.instantiate()
	get_parent().add_child(fireball)
	fireball.global_position = launch_pos
	
	# Set fireball properties based on charge
	var power = lerpf(1.0, 3.0, charge_percent)
	var speed = lerpf(MIN_SPEED, MAX_SPEED, charge_percent)
	var scale_mult = lerpf(0.5, 1.5, charge_percent)
	
	# Initialize after adding to tree to ensure collision is set up
	fireball.initialize(launch_direction, speed, power, scale_mult)
	
	# Launch particles with exaggeration
	launch_particles.global_position = charge_indicator.global_position
	launch_particles.emitting = true
	
	# Visual feedback based on charge level
	var particle_amount = int(lerpf(20.0, 80.0, charge_percent))  # More exaggerated range
	launch_particles.amount = particle_amount
	
	# Follow through: Charge indicator expands and fades (release of energy)
	var release_tween = create_tween()
	release_tween.set_parallel(true)
	release_tween.set_ease(Tween.EASE_OUT)
	release_tween.set_trans(Tween.TRANS_CUBIC)
	release_tween.tween_property(charge_indicator, "scale", charge_indicator.scale * 1.5, 0.2)
	release_tween.tween_property(charge_indicator, "modulate:a", 0.0, 0.2)
	
	await release_tween.finished
	
	# Clean up
	charge_time = 0.0
	charge_indicator.visible = false
	charge_label.text = "Click and hold to charge fireball"

func _launch_particles_at(position: Vector2, intensity: float):
	launch_particles.global_position = position
	launch_particles.amount = int(lerpf(20.0, 60.0, intensity))
	launch_particles.emitting = true
