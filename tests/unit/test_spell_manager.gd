extends GutTest

var spell_manager: Node

func before_each():
	spell_manager = get_tree().root.get_node_or_null("SpellManager")

func test_spell_manager_exists():
	assert_not_null(spell_manager, "SpellManager should be loaded as autoload")

func test_spell_manager_has_transcription_spells():
	if spell_manager:
		assert_true(spell_manager.spells.size() > 0, "SpellManager should have transcription spells")

func test_spell_manager_has_spell_registry():
	if spell_manager:
		assert_true(spell_manager.spell_registry is Dictionary, "SpellManager should have spell_registry")

func test_spell_manager_has_hotkey_spells():
	if spell_manager:
		assert_true(spell_manager.hotkey_spells is Array, "SpellManager should have hotkey_spells array")
		assert_eq(spell_manager.hotkey_spells.size(), 4, "Hotkey spells should have 4 slots")

func test_spell_manager_loaded_fireball():
	if spell_manager:
		assert_true(spell_manager.spell_registry.has("Fireball"), "SpellManager should have loaded Fireball")

func test_spell_manager_loaded_lightning():
	if spell_manager:
		assert_true(spell_manager.spell_registry.has("Lightning"), "SpellManager should have loaded Lightning")

func test_hotkey_slot_0_is_fireball():
	if spell_manager:
		var spell = spell_manager.get_hotkey_spell(0)
		assert_not_null(spell, "Hotkey slot 0 should have a spell")
		if spell:
			assert_eq(spell.spell_name, "Fireball", "Hotkey slot 0 should be Fireball")

func test_hotkey_slot_1_is_lightning():
	if spell_manager:
		var spell = spell_manager.get_hotkey_spell(1)
		assert_not_null(spell, "Hotkey slot 1 should have a spell")
		if spell:
			assert_eq(spell.spell_name, "Lightning", "Hotkey slot 1 should be Lightning")

func test_hotkey_slot_2_is_empty():
	if spell_manager:
		var spell = spell_manager.get_hotkey_spell(2)
		assert_null(spell, "Hotkey slot 2 should be empty")

func test_hotkey_slot_3_is_empty():
	if spell_manager:
		var spell = spell_manager.get_hotkey_spell(3)
		assert_null(spell, "Hotkey slot 3 should be empty")

func test_get_hotkey_spell_invalid_slot():
	if spell_manager:
		var spell = spell_manager.get_hotkey_spell(-1)
		assert_null(spell, "Invalid hotkey slot should return null")
		spell = spell_manager.get_hotkey_spell(10)
		assert_null(spell, "Invalid hotkey slot should return null")
