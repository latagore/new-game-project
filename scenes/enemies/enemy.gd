extends CharacterBody2D

@export var health = 3
@export var max_health = 3
@export var respawn_time = 3.0

var spawn_position: Vector2
var is_dead = false

func _ready():
	spawn_position = position
	max_health = health
	print("DEBUG: Enemy loaded at position: ", position)

func take_damage(amount):
	if is_dead:
		return
		
	print("DEBUG: Enemy taking damage: ", amount, " | Health: ", health, " -> ", health - amount)
	health -= amount
	if health <= 0:
		print("DEBUG: Enemy died!")
		die()

func die():
	is_dead = true
	# Hide the enemy
	visible = false
	# Disable collision
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	# Disable hurtbox
	if has_node("Hurtbox"):
		$Hurtbox.set_collision_layer_value(3, false)
		$Hurtbox.set_collision_mask_value(2, false)
	
	print("DEBUG: Enemy will respawn in ", respawn_time, " seconds")
	await get_tree().create_timer(respawn_time).timeout
	respawn()

func respawn():
	print("DEBUG: Enemy respawning at ", spawn_position)
	# Reset position
	position = spawn_position
	# Reset health
	health = max_health
	# Re-enable visibility and collision
	visible = true
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	# Re-enable hurtbox
	if has_node("Hurtbox"):
		$Hurtbox.set_collision_layer_value(3, true)
		$Hurtbox.set_collision_mask_value(2, true)
	
	is_dead = false
	print("DEBUG: Enemy respawned with ", health, " health")
