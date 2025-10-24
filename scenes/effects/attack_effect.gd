extends Node2D

@onready var sprite = $Sprite2D

func _ready():
	# Fade out and scale animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property(self, "rotation", rotation + deg_to_rad(45), 0.3)
	
	await tween.finished
	queue_free()

