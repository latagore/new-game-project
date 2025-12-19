extends CharacterBody2D

@export var speed = 300
@export var health = 10

@onready var hitbox = $Hitbox/CollisionShape2D
@onready var hitbox_node = $Hitbox
@onready var charge_indicator = $ChargeIndicator

var is_casting = false
var spell_ui = null

# Hotkey spell charging state
var is_charging_spell: bool = false
var spell_charge_time: float = 0.0
var spell_hotkey_pressed: int = -1
var active_spell: SpellData = null
const MAX_CHARGE_TIME: float = 3.0
const MIN_SCALE: float = 0.3
const MAX_SCALE: float = 1.5
const FLASH_THRESHOLD: float = 0.95
var has_flashed: bool = false

# Preload effects
var attack_effect_scene = preload("res://scenes/effects/attack_effect.tscn")
var spell_effect_scene = preload("res://scenes/effects/spell_effect.tscn")

func _ready():
	print("DEBUG: Player scene loaded and ready!")
	print("DEBUG: Player position: ", position)
	print("DEBUG: Player speed: ", speed)

	# Hide charge indicator initially
	if charge_indicator:
		charge_indicator.visible = false

func _physics_process(delta):
	# Don't allow movement while casting
	if is_casting:
		velocity = Vector2.ZERO
		return

	# Handle spell hotkey charging (continuous check like experiments)
	_handle_spell_charging(delta)

	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()

	if Input.is_action_just_pressed("attack"):
		attack()

func _handle_spell_charging(delta):
	# Check each hotkey for held state
	for i in range(4):
		var action_name = "spell_%d" % (i + 1)

		if Input.is_action_pressed(action_name):
			# Key is being held
			if not is_charging_spell or spell_hotkey_pressed != i:
				# Start charging this spell
				_start_hotkey_charge(i)
			else:
				# Continue charging
				spell_charge_time = min(spell_charge_time + delta, MAX_CHARGE_TIME)
				_update_charge_indicator()
			return  # Only one spell at a time

	# No spell key is held - release if we were charging
	if is_charging_spell:
		_release_spell()

func _input(event):
	if event.is_action_pressed("ui_accept") and not is_casting:
		# Enter key pressed - start casting mode (for transcription spells)
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

# ========== HOTKEY SPELL CHARGING ==========

func _start_hotkey_charge(slot: int):
	active_spell = SpellManager.get_hotkey_spell(slot)
	if active_spell == null:
		return

	is_charging_spell = true
	spell_charge_time = 0.0
	spell_hotkey_pressed = slot
	has_flashed = false  # Reset flash state for new charge

	# Show charge indicator
	if charge_indicator:
		charge_indicator.visible = true
		charge_indicator.scale = Vector2(0.3, 0.3)
		charge_indicator.modulate = Color(1, 0.5, 0, 0.8)

func _release_spell():
	if not is_charging_spell or active_spell == null:
		return

	# Calculate charge percent (0.0 to 1.0)
	var charge_percent = spell_charge_time / MAX_CHARGE_TIME

	# Get target position
	var target_pos = get_global_mouse_position()

	# Launch anticipation effect - quick squash before release
	if charge_indicator and charge_percent > 0.1:
		var anticipation_tween = create_tween()
		var current_scale = charge_indicator.scale
		# Quick squash in direction of target
		anticipation_tween.tween_property(charge_indicator, "scale", current_scale * Vector2(1.3, 0.7), 0.03)
		anticipation_tween.tween_property(charge_indicator, "scale", Vector2.ZERO, 0.05)

	# Cast the spell via SpellManager
	SpellManager.cast_spell_data(active_spell, self, target_pos, charge_percent)

	# Reset charging state
	is_charging_spell = false
	spell_charge_time = 0.0
	spell_hotkey_pressed = -1
	active_spell = null

	# Hide charge indicator (tween will handle visual, but ensure it's hidden after)
	if charge_indicator:
		await get_tree().create_timer(0.1).timeout
		charge_indicator.visible = false

func _update_charge_indicator():
	if charge_indicator == null:
		return

	var charge_percent = spell_charge_time / MAX_CHARGE_TIME

	# Ease in/out for scale (not linear growth) - like experiment
	var eased_percent = ease(charge_percent, -0.5)
	var current_scale = lerpf(MIN_SCALE, MAX_SCALE, eased_percent)

	# Squash & stretch: slightly oval when growing fast (early charge)
	if charge_percent < 0.3:
		var stretch_factor = 1.0 + (0.3 - charge_percent) * 0.3
		charge_indicator.scale = Vector2(current_scale / stretch_factor, current_scale * stretch_factor)
	else:
		charge_indicator.scale = Vector2(current_scale, current_scale)

	# Color shift: orange -> red -> white (hot)
	var color: Color
	if charge_percent < 0.5:
		# Orange to red
		color = Color(1, lerpf(0.5, 0.3, charge_percent * 2.0), 0)
	else:
		# Red to bright yellow-white
		var t = (charge_percent - 0.5) * 2.0
		color = Color(1, lerpf(0.3, 1.0, t), lerpf(0.0, 0.8, t))

	charge_indicator.modulate = Color(color.r, color.g, color.b, lerpf(0.5, 1.0, charge_percent))

	# Pulsing effect at high charge (secondary action)
	if charge_percent > 0.7:
		var pulse_speed = lerpf(0.01, 0.02, (charge_percent - 0.7) / 0.3)
		var pulse_intensity = lerpf(0.08, 0.15, (charge_percent - 0.7) / 0.3)
		var pulse = sin(Time.get_ticks_msec() * pulse_speed) * pulse_intensity + 1.0
		charge_indicator.scale *= pulse

	# Screen flash at max charge
	if charge_percent >= FLASH_THRESHOLD and not has_flashed:
		_trigger_max_charge_flash()
		has_flashed = true

func _trigger_max_charge_flash():
	# Squash & stretch on charge indicator at max
	var shake_tween = create_tween()
	shake_tween.tween_property(charge_indicator, "scale", charge_indicator.scale * 1.3, 0.05)
	shake_tween.tween_property(charge_indicator, "scale", charge_indicator.scale, 0.1)

func get_charge_percent() -> float:
	return spell_charge_time / MAX_CHARGE_TIME
