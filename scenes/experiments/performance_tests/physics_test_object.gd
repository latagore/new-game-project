extends RigidBody2D

var color = Color(randf(), randf(), randf())

func _ready():
	var collision_shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 8
	collision_shape.shape = circle
	add_child(collision_shape)
	
	var physics_mat = PhysicsMaterial.new()
	physics_mat.bounce = 0.8
	physics_material_override = physics_mat
	
	queue_redraw()
	
	linear_velocity = Vector2(randf_range(-200, 200), randf_range(-200, 200))

func _draw():
	draw_circle(Vector2.ZERO, 8, color)

