extends CanvasLayer

signal spell_cast_success(spell_name: String)
signal spell_cast_cancelled

@onready var panel = $Panel
@onready var spell_transcript_label = $Panel/VBoxContainer/SpellTranscript
@onready var input_label = $Panel/VBoxContainer/InputLabel
@onready var user_input_label = $Panel/VBoxContainer/UserInput

var is_casting = false
var current_spell_phrase = ""
var user_input = ""

func _ready():
	hide_ui()

func _input(event):
	if not is_casting:
		return
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			cancel_casting()
		elif event.keycode == KEY_ENTER:
			check_spell()
		elif event.keycode == KEY_BACKSPACE:
			if user_input.length() > 0:
				user_input = user_input.substr(0, user_input.length() - 1)
				update_user_input_display()
		elif event.unicode != 0:
			# Add the typed character
			var character = char(event.unicode)
			user_input += character
			update_user_input_display()

func start_casting(spell_phrase: String):
	is_casting = true
	current_spell_phrase = spell_phrase
	user_input = ""
	
	spell_transcript_label.text = "Spell: " + spell_phrase
	update_user_input_display()
	show_ui()

func cancel_casting():
	is_casting = false
	hide_ui()
	spell_cast_cancelled.emit()

func check_spell():
	# DEBUG MODE: Always succeed regardless of input
	is_casting = false
	hide_ui()
	spell_cast_success.emit(current_spell_phrase)
	
	# Original validation code (commented out for debugging)
	#if user_input.to_upper() == current_spell_phrase.to_upper():
	#	# Success!
	#	is_casting = false
	#	hide_ui()
	#	spell_cast_success.emit(current_spell_phrase)
	#else:
	#	# Failed - show feedback
	#	input_label.text = "FAILED! Try again..."
	#	user_input = ""
	#	update_user_input_display()
	#	await get_tree().create_timer(1.0).timeout
	#	input_label.text = "Type the spell:"

func update_user_input_display():
	user_input_label.text = user_input

func show_ui():
	panel.visible = true

func hide_ui():
	panel.visible = false

