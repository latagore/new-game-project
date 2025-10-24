extends CharacterBody2D

@export var speed = 300
@export var health = 10

@onready var hitbox = $Hitbox/CollisionShape2D
@onready var hitbox_node = $Hitbox

var is_casting = false
var spell_ui = null

# Preload effects
var attack_effect_scene = preload("res://scenes/effects/attack_effect.tscn")
var spell_effect_scene = preload("res://scenes/effects/spell_effect.tscn")

func _ready():
	print("DEBUG: Player scene loaded and ready!")
	print("DEBUG: Player position: ", position)
	print("DEBUG: Player speed: ", speed)

func _physics_process(delta):
	# Don't allow movement while casting
	if is_casting:
		velocity = Vector2.ZERO
		return
	
	var direction = Input.get_vector("left", "right", "up", "down")
	
	# Debug: Print when input is detected
	if direction != Vector2.ZERO:
		print("DEBUG: Input detected - direction: ", direction)
	
	velocity = direction * speed
	move_and_slide()

	if Input.is_action_just_pressed("attack"):
		print("DEBUG: Attack button pressed!")
		attack()

func _input(event):
	if event.is_action_pressed("ui_accept") and not is_casting:
		# Enter key pressed - start casting mode
		start_casting_mode()

func start_casting_mode():
	if spell_ui == null:
		# Find the spell UI in the scene
		spell_ui = get_tree().get_first_node_in_group("spell_ui")
		if spell_ui == null:
			print("ERROR: Spell UI not found!")
			return
		
		# Connect signals
		spell_ui.spell_cast_success.connect(_on_spell_cast_success)
		spell_ui.spell_cast_cancelled.connect(_on_spell_cast_cancelled)
	
	is_casting = true
	var spell_phrase = SpellManager.get_random_spell()
	spell_ui.start_casting(spell_phrase)

func _on_spell_cast_success(spell_name: String):
	print("Player: Spell cast successfully: ", spell_name)
	is_casting = false
	
	# Spawn spell effect at player position
	var effect = spell_effect_scene.instantiate()
	effect.position = position
	get_parent().add_child(effect)
	
	SpellManager.cast_spell(spell_name)

func _on_spell_cast_cancelled():
	print("Player: Spell casting cancelled")
	is_casting = false

func attack():
	print("DEBUG: Attack function called, enabling hitbox")
	print("DEBUG: Hitbox disabled state before: ", hitbox.disabled)
	
	# Position and rotate hitbox towards mouse
	var mouse_direction = global_position.direction_to(get_global_mouse_position())
	hitbox_node.rotation = mouse_direction.angle()
	# Position the hitbox in front of the player in the attack direction
	hitbox_node.position = mouse_direction * 50
	
	hitbox.disabled = false
	
	# Spawn attack effect
	var effect = attack_effect_scene.instantiate()
	effect.position = position
	# Point effect towards mouse position
	effect.rotation = mouse_direction.angle()
	get_parent().add_child(effect)
	
	print("DEBUG: Hitbox disabled state after: ", hitbox.disabled)
	await get_tree().create_timer(0.2).timeout
	hitbox.disabled = true
	print("DEBUG: Hitbox disabled again after timeout")

func take_damage(damage):
	health -= damage
	if health <= 0:
		print("Player died!")
		get_tree().reload_current_scene()
