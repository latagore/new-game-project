extends Node2D

# Lightning Bolt spell - instant raycast damage
# Performs raycast, deals damage, and shows visual effect

const BASE_DAMAGE = 30.0
const MAX_DAMAGE = 90.0  # At full charge (power = 3.0)

var lifetime = 0.3
var intensity = 1.0
var power = 1.0

@onready var main_bolt = $MainBolt
@onready var glow_bolt = $GlowBolt
@onready var flash = $Flash
@onready var impact_particles = $ImpactParticles

func initialize(start_pos: Vector2, end_pos: Vector2, pwr: float):
	global_position = start_pos
	power = pwr
	intensity = (power - 1.0) / 2.0  # 0.0 to 1.0 range

	# Perform raycast to find actual hit position
	var hit_pos = end_pos
	var hit_target = _perform_raycast(start_pos, end_pos)
	if hit_target:
		hit_pos = hit_target["position"]

		# Deal damage if target has take_damage method
		if hit_target["collider"].has_method("take_damage"):
			var damage = _calculate_damage()
			hit_target["collider"].take_damage(damage)
			print("Lightning dealt ", damage, " damage!")

	var local_end = to_local(hit_pos)

	_draw_lightning_bolt(main_bolt, Vector2.ZERO, local_end, 2, intensity)
	_draw_lightning_bolt(glow_bolt, Vector2.ZERO, local_end, 1, intensity)

	main_bolt.width = lerpf(3.0, 8.0, intensity)
	glow_bolt.width = lerpf(8.0, 20.0, intensity)

	var color_intensity = lerpf(0.6, 1.0, intensity)
	main_bolt.modulate = Color(color_intensity, color_intensity, 1.0, 1.0)
	glow_bolt.modulate = Color(0.5, 0.8, 1.0, lerpf(0.3, 0.6, intensity))

	flash.global_position = hit_pos
	flash.scale = Vector2.ONE * lerpf(0.5, 1.2, intensity)
	flash.modulate = Color(0.7, 0.9, 1.0, 0.8)

	var flash_tween = create_tween()
	flash_tween.set_parallel(true)
	flash_tween.set_ease(Tween.EASE_OUT)
	flash_tween.tween_property(flash, "scale", flash.scale * 2.0, 0.15)
	flash_tween.tween_property(flash, "modulate:a", 0.0, 0.15)

	impact_particles.global_position = hit_pos
	impact_particles.amount = int(lerpf(20.0, 60.0, intensity))
	impact_particles.emitting = true

	_animate_lightning()

func _calculate_damage() -> float:
	# Lerp damage based on power (1.0 to 3.0)
	var t = (power - 1.0) / 2.0
	return lerpf(BASE_DAMAGE, MAX_DAMAGE, t)

func _perform_raycast(origin: Vector2, target: Vector2) -> Variant:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(origin, target)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	# Collision mask 4 = hurtboxes (layer 4)
	query.collision_mask = 4

	var result = space_state.intersect_ray(query)
	if result:
		return {"position": result.position, "collider": result.collider}
	return null

func _draw_lightning_bolt(line: Line2D, start: Vector2, end: Vector2, segments: int, jaggedness: float):
	line.clear_points()
	line.add_point(start)

	var current = start
	var target = end
	var direction = start.direction_to(end)
	var distance = start.distance_to(end)
	var segment_length = distance / segments

	for i in range(segments):
		var next_point: Vector2
		if i == segments - 1:
			next_point = end
		else:
			var progress = float(i + 1) / segments
			next_point = start.lerp(end, progress)

			var perpendicular = Vector2(-direction.y, direction.x)
			var offset = randf_range(-30.0, 30.0) * jaggedness
			next_point += perpendicular * offset

		line.add_point(next_point)

func _animate_lightning():
	var flicker_count = int(lerpf(2.0, 5.0, intensity))

	for i in range(flicker_count):
		await get_tree().create_timer(randf_range(0.03, 0.08)).timeout
		main_bolt.visible = not main_bolt.visible
		glow_bolt.visible = not glow_bolt.visible

	var fade_tween = create_tween()
	fade_tween.set_parallel(true)
	fade_tween.set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(main_bolt, "modulate:a", 0.0, 0.15)
	fade_tween.tween_property(glow_bolt, "modulate:a", 0.0, 0.15)

	await fade_tween.finished

	await get_tree().create_timer(0.5).timeout
	queue_free()
