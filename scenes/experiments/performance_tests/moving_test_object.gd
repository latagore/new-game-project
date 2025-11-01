extends Node2D

var velocity = Vector2.ZERO
var is_moving = true
var color = Color(randf(), randf(), randf())

func _ready():
	queue_redraw()

func _process(delta):
	if is_moving:
		position += velocity * delta
		
		# Bounce off screen edges
		var viewport_size = get_viewport_rect().size
		if position.x < 0 or position.x > viewport_size.x:
			velocity.x = -velocity.x
			position.x = clamp(position.x, 0, viewport_size.x)
		if position.y < 0 or position.y > viewport_size.y:
			velocity.y = -velocity.y
			position.y = clamp(position.y, 0, viewport_size.y)

func _draw():
	draw_circle(Vector2.ZERO, 3, color)

