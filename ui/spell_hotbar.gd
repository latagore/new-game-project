extends HBoxContainer

# Spell Hotbar UI - Shows 4 hotkey slots with spell assignments

@onready var slots: Array[Control] = []

func _ready():
	_create_slots()
	_update_slots()

func _create_slots():
	for i in range(4):
		var slot = _create_slot(i + 1)
		add_child(slot)
		slots.append(slot)

func _create_slot(hotkey_num: int) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(60, 60)

	var vbox = VBoxContainer.new()
	vbox.name = "VBoxContainer"
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	# Hotkey number label
	var hotkey_label = Label.new()
	hotkey_label.name = "HotkeyLabel"
	hotkey_label.text = str(hotkey_num)
	hotkey_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hotkey_label.add_theme_font_size_override("font_size", 20)
	hotkey_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	vbox.add_child(hotkey_label)

	# Spell name label
	var spell_label = Label.new()
	spell_label.name = "SpellLabel"
	spell_label.text = "-"
	spell_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	spell_label.add_theme_font_size_override("font_size", 10)
	vbox.add_child(spell_label)

	return panel

func _update_slots():
	for i in range(4):
		var spell = SpellManager.get_hotkey_spell(i)
		var spell_label = slots[i].get_node("VBoxContainer/SpellLabel") as Label
		if spell:
			spell_label.text = spell.spell_name
		else:
			spell_label.text = "-"
