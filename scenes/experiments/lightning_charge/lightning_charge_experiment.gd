extends Node2D

const MAX_CHARGE_TIME = 3.0
const MIN_DAMAGE = 30.0
const MAX_DAMAGE = 150.0
const MAX_RANGE = 1500.0
const FLASH_THRESHOLD = 0.95

var is_charging = false
var charge_time = 0.0
var has_flashed = false
var current_target = null

@onready var charge_indicator = $ChargeIndicator
@onready var targeting_reticle = $TargetingReticle
@onready var target_line = $TargetLine
@onready var flash_overlay = $CanvasLayer/FlashOverlay
@onready var charge_label = $CanvasLayer/ChargeLabel

var lightning_bolt_scene = preload("res://scenes/experiments/lightning_charge/lightning_bolt.tscn")

func _ready():
	flash_overlay.modulate = Color(1, 1, 1, 0)
	targeting_reticle.visible = false
	target_line.visible = false
	charge_indicator.visible = false
	charge_indicator.scale = Vector2.ZERO

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not is_charging:
			_start_charging()
		_update_charge(delta)
	elif is_charging:
		_release_lightning()
	
	if is_charging:
		_update_targeting()

func _start_charging():
	is_charging = true
	charge_time = 0.0
	has_flashed = false
	targeting_reticle.visible = true
	target_line.visible = true
	charge_indicator.visible = true
	charge_indicator.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(charge_indicator, "scale", Vector2(0.5, 0.5), 0.15)

func _update_charge(delta):
	charge_time = min(charge_time + delta, MAX_CHARGE_TIME)
	var charge_percent = charge_time / MAX_CHARGE_TIME
	
	var eased_percent = ease(charge_percent, -0.5)
	var current_scale = lerpf(0.5, 1.5, eased_percent)
	
	charge_indicator.scale = Vector2(current_scale, current_scale)
	
	var color: Color
	if charge_percent < 0.5:
		color = Color(lerpf(0.3, 0.6, charge_percent * 2.0), lerpf(0.5, 0.8, charge_percent * 2.0), 1.0)
	else:
		var t = (charge_percent - 0.5) * 2.0
		color = Color(lerpf(0.6, 1.0, t), lerpf(0.8, 1.0, t), 1.0)
	
	charge_indicator.modulate = Color(color.r, color.g, color.b, lerpf(0.5, 1.0, charge_percent))
	
	if charge_percent > 0.7:
		var pulse_speed = lerpf(0.01, 0.02, (charge_percent - 0.7) / 0.3)
		var pulse_intensity = lerpf(0.08, 0.15, (charge_percent - 0.7) / 0.3)
		var pulse = sin(Time.get_ticks_msec() * pulse_speed) * pulse_intensity + 1.0
		charge_indicator.scale *= pulse
	
	if charge_percent >= FLASH_THRESHOLD and not has_flashed:
		_trigger_max_charge_flash()
		has_flashed = true
	
	var damage = lerpf(MIN_DAMAGE, MAX_DAMAGE, charge_percent)
	charge_label.text = "Charge: %.1f%% (Hold: %.2fs)\nDamage: %.0f\nTarget: %s" % [
		charge_percent * 100.0,
		charge_time,
		damage,
		current_target.name if current_target else "None"
	]

func _update_targeting():
	var mouse_pos = get_global_mouse_position()
	targeting_reticle.global_position = mouse_pos
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, mouse_pos)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	if result:
		current_target = result.collider
		targeting_reticle.modulate = Color(1.0, 0.3, 0.3)
		_highlight_target(current_target, true)
	else:
		if current_target:
			_highlight_target(current_target, false)
		current_target = null
		targeting_reticle.modulate = Color(0.5, 0.8, 1.0)
	
	target_line.clear_points()
	target_line.add_point(Vector2.ZERO)
	target_line.add_point(to_local(mouse_pos))
	
	var charge_percent = charge_time / MAX_CHARGE_TIME
	target_line.width = lerpf(1.0, 3.0, charge_percent)
	target_line.modulate = Color(0.5, 0.8, 1.0, lerpf(0.2, 0.5, charge_percent))

func _highlight_target(target, highlight: bool):
	if target and target.has_method("set_highlighted"):
		target.set_highlighted(highlight)

func _trigger_max_charge_flash():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	flash_overlay.modulate = Color(0.5, 0.8, 1.0, 0.0)
	tween.tween_property(flash_overlay, "modulate:a", 0.4, 0.05)
	tween.tween_property(flash_overlay, "modulate:a", 0.0, 0.3)
	
	var shake_tween = create_tween()
	shake_tween.tween_property(charge_indicator, "scale", charge_indicator.scale * 1.2, 0.05)
	shake_tween.tween_property(charge_indicator, "scale", charge_indicator.scale, 0.1)

func _release_lightning():
	var charge_percent = charge_time / MAX_CHARGE_TIME
	var damage = lerpf(MIN_DAMAGE, MAX_DAMAGE, charge_percent)
	var origin = global_position
	var target_pos = get_global_mouse_position()
	
	is_charging = false
	targeting_reticle.visible = false
	target_line.visible = false
	
	if current_target:
		_highlight_target(current_target, false)
	
	var anticipation_tween = create_tween()
	anticipation_tween.set_parallel(true)
	anticipation_tween.tween_property(charge_indicator, "scale", charge_indicator.scale * 0.7, 0.08)
	await anticipation_tween.finished
	
	_perform_raycast_strike(origin, target_pos, damage, charge_percent)
	
	var release_tween = create_tween()
	release_tween.set_parallel(true)
	release_tween.set_ease(Tween.EASE_OUT)
	release_tween.set_trans(Tween.TRANS_CUBIC)
	release_tween.tween_property(charge_indicator, "scale", charge_indicator.scale * 1.5, 0.2)
	release_tween.tween_property(charge_indicator, "modulate:a", 0.0, 0.2)
	
	await release_tween.finished
	
	charge_time = 0.0
	charge_indicator.visible = false
	current_target = null
	charge_label.text = "Click and hold to charge lightning"

func _perform_raycast_strike(origin: Vector2, target: Vector2, damage: float, intensity: float):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(origin, target)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var hit_position = target
	var hit_target = null
	
	var result = space_state.intersect_ray(query)
	if result:
		hit_position = result.position
		hit_target = result.collider
	
	var lightning = lightning_bolt_scene.instantiate()
	get_parent().add_child(lightning)
	lightning.initialize(origin, hit_position, intensity)
	
	if hit_target and hit_target.has_method("take_damage"):
		hit_target.take_damage(damage)



