extends GutTest

var TypingSpellInput = preload("res://scripts/input/typing_spell_input.gd")

var typing: Node

func before_each():
	typing = TypingSpellInput.new()
	add_child_autofree(typing)

func test_typing_input_loads():
	assert_not_null(typing, "Typing spell input should load")

func test_typing_input_has_spells():
	assert_true(typing.spells.size() > 0, "Should have spell definitions")

func test_has_single_letter_spells():
	assert_true("f" in typing.spells, "Should have 'f' spell")
	assert_true("i" in typing.spells, "Should have 'i' spell")
	assert_true("l" in typing.spells, "Should have 'l' spell")

func test_has_word_spells():
	assert_true("fire" in typing.spells, "Should have 'fire' spell")
	assert_true("ice" in typing.spells, "Should have 'ice' spell")
	assert_true("bolt" in typing.spells, "Should have 'bolt' spell")

func test_has_long_spells():
	assert_true("firestorm" in typing.spells, "Should have 'firestorm' spell")
	assert_true("blizzard" in typing.spells, "Should have 'blizzard' spell")
	assert_true("thunder" in typing.spells, "Should have 'thunder' spell")

func test_spell_power_scaling():
	# Single letters should be weakest
	assert_lt(typing.get_spell_power("f"), typing.get_spell_power("fire"))
	# Words should be less than long words
	assert_lt(typing.get_spell_power("fire"), typing.get_spell_power("firestorm"))

func test_spell_elements():
	assert_eq(typing.get_spell_element("f"), "fire")
	assert_eq(typing.get_spell_element("fire"), "fire")
	assert_eq(typing.get_spell_element("i"), "ice")
	assert_eq(typing.get_spell_element("ice"), "ice")
	assert_eq(typing.get_spell_element("l"), "lightning")

func test_initial_state():
	assert_eq(typing.get_buffer(), "", "Buffer should be empty")
	assert_false(typing.is_spell_ready(), "No spell should be ready")
	assert_false(typing.is_typing, "Should not be typing")

func test_valid_prefix():
	assert_true(typing._is_valid_prefix("f"), "'f' is a valid prefix")
	assert_true(typing._is_valid_prefix("fi"), "'fi' is a valid prefix (for fire/firestorm)")
	assert_true(typing._is_valid_prefix("fir"), "'fir' is a valid prefix")
	assert_false(typing._is_valid_prefix("xyz"), "'xyz' is not a valid prefix")

func test_get_spells_with_prefix():
	var fire_spells = typing.get_spells_with_prefix("fire")
	assert_true("fire" in fire_spells, "Should include 'fire'")
	assert_true("firestorm" in fire_spells, "Should include 'firestorm'")

func test_get_all_spells():
	var all_spells = typing.get_all_spells()
	assert_gt(all_spells.size(), 5, "Should have multiple spells")

func test_get_spell_name():
	assert_eq(typing.get_spell_name("f"), "spark")
	assert_eq(typing.get_spell_name("fire"), "fireball")
	assert_eq(typing.get_spell_name("firestorm"), "firestorm")

func test_unknown_spell_returns_empty():
	assert_eq(typing.get_spell_name("xyz"), "")
	assert_eq(typing.get_spell_power("xyz"), 0.0)
	assert_eq(typing.get_spell_element("xyz"), "")

func test_combo_patterns():
	assert_true("ff" in typing.spells, "Should have 'ff' combo")
	assert_true("iii" in typing.spells, "Should have 'iii' combo")
