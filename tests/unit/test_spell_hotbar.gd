extends GutTest

var SpellHotbar = preload("res://ui/spell_hotbar.tscn")

func test_spell_hotbar_loads():
	assert_not_null(SpellHotbar, "Spell hotbar scene should load")

func test_spell_hotbar_instantiates():
	var hotbar = SpellHotbar.instantiate()
	assert_not_null(hotbar, "Spell hotbar should instantiate")
	hotbar.queue_free()

func test_spell_hotbar_creates_4_slots():
	var hotbar = SpellHotbar.instantiate()
	add_child_autofree(hotbar)

	# Wait for _ready to complete
	await wait_frames(1)

	assert_eq(hotbar.slots.size(), 4, "Hotbar should have 4 slots")

func test_spell_hotbar_slots_have_labels():
	var hotbar = SpellHotbar.instantiate()
	add_child_autofree(hotbar)

	await wait_frames(1)

	for i in range(4):
		var slot = hotbar.slots[i]
		var hotkey_label = slot.get_node("VBoxContainer/HotkeyLabel")
		var spell_label = slot.get_node("VBoxContainer/SpellLabel")
		assert_not_null(hotkey_label, "Slot %d should have HotkeyLabel" % i)
		assert_not_null(spell_label, "Slot %d should have SpellLabel" % i)

func test_spell_hotbar_shows_hotkey_numbers():
	var hotbar = SpellHotbar.instantiate()
	add_child_autofree(hotbar)

	await wait_frames(1)

	for i in range(4):
		var slot = hotbar.slots[i]
		var hotkey_label = slot.get_node("VBoxContainer/HotkeyLabel") as Label
		assert_eq(hotkey_label.text, str(i + 1), "Slot %d should show hotkey %d" % [i, i + 1])

func test_spell_hotbar_shows_spell_names():
	var hotbar = SpellHotbar.instantiate()
	add_child_autofree(hotbar)

	await wait_frames(1)

	# Slot 0 should show Fireball
	var slot0_spell = hotbar.slots[0].get_node("VBoxContainer/SpellLabel") as Label
	assert_eq(slot0_spell.text, "Fireball", "Slot 0 should show Fireball")

	# Slot 1 should show Lightning
	var slot1_spell = hotbar.slots[1].get_node("VBoxContainer/SpellLabel") as Label
	assert_eq(slot1_spell.text, "Lightning", "Slot 1 should show Lightning")

func test_spell_hotbar_empty_slots_show_dash():
	var hotbar = SpellHotbar.instantiate()
	add_child_autofree(hotbar)

	await wait_frames(1)

	# Slots 2 and 3 should show "-"
	var slot2_spell = hotbar.slots[2].get_node("VBoxContainer/SpellLabel") as Label
	var slot3_spell = hotbar.slots[3].get_node("VBoxContainer/SpellLabel") as Label
	assert_eq(slot2_spell.text, "-", "Empty slot 2 should show dash")
	assert_eq(slot3_spell.text, "-", "Empty slot 3 should show dash")
