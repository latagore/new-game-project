extends Area2D

signal hurt(damage)
@export var debug_color = Color(0, 1, 0, 0.3)  # Green semi-transparent

func _init():
	collision_layer = 4
	collision_mask = 2

func _ready():
	print("DEBUG: Hurtbox ready on: ", get_parent().name)
	print("DEBUG: Hurtbox collision_layer: ", collision_layer)
	print("DEBUG: Hurtbox collision_mask: ", collision_mask)
	
	# Add visual debug shape
	_add_debug_visual()

func _add_debug_visual():
	# Find the collision shape
	for child in get_children():
		if child is CollisionShape2D:
			var shape = child.shape
			if shape is RectangleShape2D:
				var rect = ColorRect.new()
				rect.size = shape.size
				rect.position = -shape.size / 2
				rect.color = debug_color
				child.add_child(rect)
			elif shape is CircleShape2D:
				var circle = _create_circle_visual(shape.radius)
				child.add_child(circle)
			elif shape is CapsuleShape2D:
				var capsule = _create_capsule_visual(shape.radius, shape.height)
				child.add_child(capsule)

func _create_circle_visual(radius):
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()
	var segments = 32
	for i in range(segments):
		var angle = i * TAU / segments
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	polygon.polygon = points
	polygon.color = debug_color
	return polygon

func _create_capsule_visual(radius, height):
	var polygon = Polygon2D.new()
	var points = PackedVector2Array()
	var segments = 16
	var half_height = (height - radius * 2) / 2
	
	# Top semicircle
	for i in range(segments / 2 + 1):
		var angle = PI + i * PI / (segments / 2)
		points.append(Vector2(cos(angle) * radius, sin(angle) * radius - half_height))
	
	# Bottom semicircle
	for i in range(segments / 2 + 1):
		var angle = i * PI / (segments / 2)
		points.append(Vector2(cos(angle) * radius, sin(angle) * radius + half_height))
	
	polygon.polygon = points
	polygon.color = debug_color
	return polygon

func take_damage(damage):
	print("DEBUG: Hurtbox taking damage: ", damage)
	emit_signal("hurt", damage)
