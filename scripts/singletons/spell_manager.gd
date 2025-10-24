extends Node

# Preload enemy death effect
var enemy_spell_death_effect = preload("res://scenes/effects/enemy_spell_death.tscn")

# List of available spells
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

