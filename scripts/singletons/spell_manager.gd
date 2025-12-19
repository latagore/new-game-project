extends Node

# Preload enemy death effect
var enemy_spell_death_effect = preload("res://scenes/effects/enemy_spell_death.tscn")

# ========== TRANSCRIPTION SPELLS (typing-based) ==========
var spells = {
	"IGNIS MAJORIS": {
		"description": "A powerful fire spell that destroys all enemies",
		"effect": "destroy_all_enemies"
	},
	"GLACIES AETERNA": {
		"description": "Freezes all enemies in place",
		"effect": "freeze_all_enemies"
	}
}

# Current available spell phrases
var available_spells = ["IGNIS MAJORIS"]

# ========== HOTKEY SPELLS (SpellData-based) ==========
var spell_registry: Dictionary = {}  # spell_name -> SpellData
var hotkey_spells: Array = [null, null, null, null]  # slots 0-3 (keys 1-4)

func _ready():
	_load_spell_resources()

func _load_spell_resources():
	# Load all spell resources from the spells directory
	var spell_paths = [
		"res://resources/spells/fireball.tres",
		"res://resources/spells/lightning.tres"
	]

	for path in spell_paths:
		if ResourceLoader.exists(path):
			var spell_data: SpellData = load(path)
			if spell_data:
				spell_registry[spell_data.spell_name] = spell_data
				# Assign to hotkey slot if specified
				if spell_data.hotkey_index >= 0 and spell_data.hotkey_index < 4:
					hotkey_spells[spell_data.hotkey_index] = spell_data
				print("Loaded spell: ", spell_data.spell_name, " (hotkey: ", spell_data.hotkey_index + 1, ")")

func get_hotkey_spell(slot: int) -> SpellData:
	if slot >= 0 and slot < 4:
		return hotkey_spells[slot]
	return null

func cast_hotkey_spell(slot: int, caster: Node, target_position: Vector2, charge_percent: float = 0.0):
	var spell_data = get_hotkey_spell(slot)
	if spell_data == null:
		print("No spell assigned to hotkey ", slot + 1)
		return

	cast_spell_data(spell_data, caster, target_position, charge_percent)

func cast_spell_data(spell_data: SpellData, caster: Node, target_position: Vector2, charge_percent: float = 0.0):
	# Convert charge_percent (0-1) to power (1-3)
	var power = 1.0 + (charge_percent * 2.0)

	match spell_data.behavior_type:
		"projectile":
			_cast_projectile(spell_data, caster, target_position, power)
		"raycast":
			_cast_raycast(spell_data, caster, target_position, power)
		"instant":
			_cast_instant(spell_data, caster)
		_:
			print("Unknown behavior type: ", spell_data.behavior_type)

func _cast_projectile(spell_data: SpellData, caster: Node, target_position: Vector2, power: float):
	if spell_data.projectile_scene == null:
		print("No projectile scene for ", spell_data.spell_name)
		return

	var projectile = spell_data.projectile_scene.instantiate()
	caster.get_parent().add_child(projectile)
	projectile.global_position = caster.global_position

	var direction = caster.global_position.direction_to(target_position)
	var speed = lerpf(spell_data.speed, spell_data.max_speed, (power - 1.0) / 2.0)

	if projectile.has_method("initialize"):
		projectile.initialize(direction, speed, power, 1.0)

	print("Cast ", spell_data.spell_name, " (power: ", power, ")")

func _cast_raycast(spell_data: SpellData, caster: Node, target_position: Vector2, power: float):
	if spell_data.projectile_scene == null:
		print("No effect scene for ", spell_data.spell_name)
		return

	var effect = spell_data.projectile_scene.instantiate()
	caster.get_parent().add_child(effect)

	if effect.has_method("initialize"):
		effect.initialize(caster.global_position, target_position, power)

	print("Cast ", spell_data.spell_name, " (power: ", power, ")")

func _cast_instant(spell_data: SpellData, caster: Node):
	print("Cast instant spell: ", spell_data.spell_name)
	# Placeholder for instant spells (buffs, heals, etc.)

func get_random_spell() -> String:
	if available_spells.is_empty():
		return "IGNIS MAJORIS"  # Default spell
	return available_spells[randi() % available_spells.size()]

func cast_spell(spell_name: String):
	print("Casting spell: ", spell_name)
	
	if not spells.has(spell_name):
		print("Unknown spell: ", spell_name)
		return
	
	var spell_data = spells[spell_name]
	var effect = spell_data["effect"]
	
	match effect:
		"destroy_all_enemies":
			destroy_all_enemies()
		"freeze_all_enemies":
			freeze_all_enemies()
		_:
			print("Unknown spell effect: ", effect)

func destroy_all_enemies():
	print("Destroying all enemies!")
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("die"):
			# Spawn visual effect at enemy position
			var effect = enemy_spell_death_effect.instantiate()
			effect.position = enemy.global_position
			enemy.get_parent().add_child(effect)
			
			enemy.die()

func freeze_all_enemies():
	print("Freezing all enemies!")
	# Placeholder for future implementation
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		print("Enemy frozen: ", enemy.name)

