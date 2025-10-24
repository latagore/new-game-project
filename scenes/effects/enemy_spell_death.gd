extends Node2D

@onready var particles = $CPUParticles2D
@onready var sprite = $Sprite2D

func _ready():
	# Restart particles to trigger one-shot emission
	particles.emitting = true
	particles.restart()
	
	# Animate sprite
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.5)
	tween.tween_property(sprite, "rotation", deg_to_rad(360), 0.5)
	
	# Clean up after effect is done
	await get_tree().create_timer(1.5).timeout
	queue_free()

