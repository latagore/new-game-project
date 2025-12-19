extends Node2D

# Combat Prototype Test Scene
# This scene is for testing combat implementations step by step.
#
# Step 1: F key spawns fireball - DONE
# Step 2: G key fires lightning - DONE
# Step 3: Spells routed through SpellManager - DONE
# Step 4: 1/2 keys cast via player hotkeys - DONE
# Step 5: Charging mechanics added - DONE
# Step 6: Enemy AI added

@onready var player = $Player

func _ready():
	print("=== Combat Prototype Test Scene ===")
	print("Current step: Step 5 - Charging mechanics")
	print("")
	print("Controls:")
	print("  WASD - Move")
	print("  Space/Click - Melee attack")
	print("  F - Fireball (quick cast)")
	print("  G - Lightning (quick cast)")
	print("  HOLD 1 - Charge Fireball (release to cast)")
	print("  HOLD 2 - Charge Lightning (release to cast)")
	print("")
	print("Charging: Hold 1/2 to charge, release to cast. Longer charge = more power!")
	print("")

	# Verify SpellManager loaded spells
	if SpellManager.spell_registry.size() > 0:
		print("SpellManager loaded ", SpellManager.spell_registry.size(), " spells")
	else:
		print("WARNING: No spells loaded in SpellManager")

func _input(event):
	if player == null:
		return

	if not event is InputEventKey or not event.pressed:
		return

	# F key - Quick Fireball (no charge)
	if event.keycode == KEY_F:
		_cast_fireball()

	# G key - Quick Lightning (no charge)
	if event.keycode == KEY_G:
		_cast_lightning()

func _cast_fireball():
	var target_pos = get_global_mouse_position()
	SpellManager.cast_hotkey_spell(0, player, target_pos, 0.0)

func _cast_lightning():
	var target_pos = get_global_mouse_position()
	SpellManager.cast_hotkey_spell(1, player, target_pos, 0.0)

func _cast_hotkey(slot: int):
	var target_pos = get_global_mouse_position()
	SpellManager.cast_hotkey_spell(slot, player, target_pos, 0.0)
