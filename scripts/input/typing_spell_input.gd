class_name TypingSpellInput
extends Node

## Captures keyboard input for spell casting.
## Type spell names to prepare them, then click to cast.

signal typing_started()
signal typing_updated(buffer: String, is_valid_prefix: bool)
signal spell_ready(spell_name: String)
signal spell_cast(spell_name: String, power: float)
signal typing_failed()
signal typing_cleared()

# Configuration
@export var input_timeout: float = 2.0  # Clear buffer after this many seconds
@export var allow_while_moving: bool = true

# Spell dictionary: typed text -> spell name
var spells = {
	# Single letter - fast but weak
	"f": {"spell": "spark", "power": 0.3, "element": "fire"},
	"i": {"spell": "ice_shard", "power": 0.3, "element": "ice"},
	"l": {"spell": "zap", "power": 0.3, "element": "lightning"},

	# Short words - medium power
	"fire": {"spell": "fireball", "power": 0.6, "element": "fire"},
	"ice": {"spell": "ice_lance", "power": 0.6, "element": "ice"},
	"bolt": {"spell": "lightning_bolt", "power": 0.6, "element": "lightning"},

	# Long words - high power
	"firestorm": {"spell": "firestorm", "power": 1.0, "element": "fire"},
	"blizzard": {"spell": "blizzard", "power": 1.0, "element": "ice"},
	"thunder": {"spell": "thunderstorm", "power": 1.0, "element": "lightning"},

	# Combo patterns
	"ff": {"spell": "double_spark", "power": 0.5, "element": "fire"},
	"iii": {"spell": "ice_barrage", "power": 0.7, "element": "ice"},
}

# State
var buffer: String = ""
var last_input_time: float = 0.0
var ready_spell: String = ""
var is_typing: bool = false

func _ready():
	set_process_input(true)
	set_process(true)

func _process(delta: float):
	# Clear buffer on timeout
	if buffer.length() > 0:
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_input_time > input_timeout:
			_clear_buffer()

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		# Only handle letter keys
		var keycode = event.keycode
		if keycode >= KEY_A and keycode <= KEY_Z:
			var letter = char(keycode).to_lower()
			_add_letter(letter)

		# Backspace to delete
		elif keycode == KEY_BACKSPACE:
			_delete_letter()

		# Escape to clear
		elif keycode == KEY_ESCAPE:
			_clear_buffer()

	# Click to cast ready spell
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if ready_spell != "":
				_cast_ready_spell()

func _add_letter(letter: String):
	if not is_typing and buffer.length() == 0:
		is_typing = true
		typing_started.emit()

	buffer += letter
	last_input_time = Time.get_ticks_msec() / 1000.0

	# Check if buffer matches a spell
	if buffer in spells:
		ready_spell = buffer
		spell_ready.emit(spells[buffer].spell)
		typing_updated.emit(buffer, true)
	# Check if buffer is a valid prefix
	elif _is_valid_prefix(buffer):
		ready_spell = ""
		typing_updated.emit(buffer, true)
	else:
		# Invalid - clear and signal failure
		typing_failed.emit()
		_clear_buffer()

func _delete_letter():
	if buffer.length() > 0:
		buffer = buffer.substr(0, buffer.length() - 1)
		last_input_time = Time.get_ticks_msec() / 1000.0

		if buffer.length() == 0:
			_clear_buffer()
		elif buffer in spells:
			ready_spell = buffer
			spell_ready.emit(spells[buffer].spell)
			typing_updated.emit(buffer, true)
		else:
			ready_spell = ""
			typing_updated.emit(buffer, _is_valid_prefix(buffer))

func _clear_buffer():
	buffer = ""
	ready_spell = ""
	is_typing = false
	typing_cleared.emit()

func _cast_ready_spell():
	if ready_spell == "" or ready_spell not in spells:
		return

	var spell_data = spells[ready_spell]
	spell_cast.emit(spell_data.spell, spell_data.power)

	_clear_buffer()

func _is_valid_prefix(text: String) -> bool:
	for key in spells.keys():
		if key.begins_with(text):
			return true
	return false

# Public API
func get_spell_power(typed_text: String) -> float:
	if typed_text in spells:
		return spells[typed_text].power
	return 0.0

func get_spell_element(typed_text: String) -> String:
	if typed_text in spells:
		return spells[typed_text].element
	return ""

func get_spell_name(typed_text: String) -> String:
	if typed_text in spells:
		return spells[typed_text].spell
	return ""

func get_buffer() -> String:
	return buffer

func get_ready_spell() -> String:
	return ready_spell

func is_spell_ready() -> bool:
	return ready_spell != ""

func get_all_spells() -> Array:
	return spells.keys()

func get_spells_with_prefix(prefix: String) -> Array:
	var result = []
	for key in spells.keys():
		if key.begins_with(prefix):
			result.append(key)
	return result
