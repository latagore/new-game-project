extends Node2D

@onready var particles = $CPUParticles2D

func _ready():
	# Restart particles to trigger one-shot emission
	particles.emitting = true
	particles.restart()
	
	# Clean up after particles are done
	await get_tree().create_timer(2.0).timeout
	queue_free()

