class_name RhythmPattern
extends Node

## Recognizes click timing patterns for spell casting.
## Players must click to match a rhythm pattern.

signal pattern_started(pattern_name: String)
signal beat_hit(accuracy: float)  # 0-1, 1 = perfect
signal beat_missed()
signal pattern_complete(pattern_name: String, score: float)
signal pattern_failed(pattern_name: String)

# Configuration
@export var perfect_window: float = 0.08  # Seconds for perfect hit
@export var good_window: float = 0.15  # Seconds for good hit
@export var ok_window: float = 0.25  # Seconds for acceptable hit
@export var base_tempo: float = 120.0  # BPM

# Patterns: Array of beat timings (in beats, 1.0 = one beat)
var patterns = {
	"spark": {
		"beats": [0.0, 1.0, 2.0],  # Three even clicks
		"spell": "spark",
		"complexity": 1
	},
	"fireball": {
		"beats": [0.0, 0.5, 1.5, 2.0],  # quick-quick-pause-quick
		"spell": "fireball",
		"complexity": 2
	},
	"lightning": {
		"beats": [0.0, 0.25, 0.5, 1.5, 1.75, 2.0],  # triple-pause-triple
		"spell": "lightning",
		"complexity": 3
	},
	"meteor": {
		"beats": [0.0, 0.5, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0],  # Complex pattern
		"spell": "meteor",
		"complexity": 4
	}
}

# State
var active_pattern: String = ""
var pattern_start_time: float = 0.0
var current_beat_index: int = 0
var hits: Array[float] = []  # Accuracy of each hit
var tempo_multiplier: float = 1.0

func _ready():
	set_process_input(true)

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if active_pattern != "":
				_handle_click()

func start_pattern(pattern_name: String, tempo_mult: float = 1.0):
	if pattern_name not in patterns:
		return false

	active_pattern = pattern_name
	pattern_start_time = Time.get_ticks_msec() / 1000.0
	current_beat_index = 0
	hits.clear()
	tempo_multiplier = tempo_mult

	pattern_started.emit(pattern_name)
	return true

func cancel_pattern():
	if active_pattern != "":
		pattern_failed.emit(active_pattern)
	active_pattern = ""
	current_beat_index = 0
	hits.clear()

func _handle_click():
	var pattern = patterns[active_pattern]
	var beats = pattern.beats

	if current_beat_index >= beats.size():
		return

	var current_time = Time.get_ticks_msec() / 1000.0
	var elapsed = current_time - pattern_start_time

	# Convert elapsed time to beats
	var beat_duration = 60.0 / (base_tempo * tempo_multiplier)
	var current_beat = elapsed / beat_duration

	# Expected beat
	var expected_beat = beats[current_beat_index]
	var beat_diff = abs(current_beat - expected_beat)

	# Convert beat difference to time difference
	var time_diff = beat_diff * beat_duration

	var accuracy = _calculate_accuracy(time_diff)

	if accuracy > 0:
		hits.append(accuracy)
		beat_hit.emit(accuracy)
		current_beat_index += 1

		# Check if pattern complete
		if current_beat_index >= beats.size():
			_complete_pattern()
	else:
		beat_missed.emit()
		# Too early or too late - fail the pattern
		pattern_failed.emit(active_pattern)
		active_pattern = ""
		hits.clear()

func _calculate_accuracy(time_diff: float) -> float:
	if time_diff <= perfect_window:
		return 1.0
	elif time_diff <= good_window:
		return 0.8
	elif time_diff <= ok_window:
		return 0.5
	else:
		return 0.0  # Miss

func _complete_pattern():
	var avg_accuracy = 0.0
	for h in hits:
		avg_accuracy += h
	avg_accuracy /= hits.size()

	pattern_complete.emit(active_pattern, avg_accuracy)
	active_pattern = ""
	hits.clear()

func get_pattern_spell(pattern_name: String) -> String:
	if pattern_name in patterns:
		return patterns[pattern_name].spell
	return ""

func get_pattern_complexity(pattern_name: String) -> int:
	if pattern_name in patterns:
		return patterns[pattern_name].complexity
	return 0

func get_pattern_beats(pattern_name: String) -> Array:
	if pattern_name in patterns:
		return patterns[pattern_name].beats
	return []

func get_pattern_duration(pattern_name: String) -> float:
	if pattern_name in patterns:
		var beats = patterns[pattern_name].beats
		if beats.size() > 0:
			var beat_duration = 60.0 / (base_tempo * tempo_multiplier)
			return beats[-1] * beat_duration
	return 0.0

func get_expected_beat_time(pattern_name: String, beat_index: int) -> float:
	if pattern_name in patterns:
		var beats = patterns[pattern_name].beats
		if beat_index < beats.size():
			var beat_duration = 60.0 / (base_tempo * tempo_multiplier)
			return beats[beat_index] * beat_duration
	return -1.0

func is_pattern_active() -> bool:
	return active_pattern != ""

func get_current_beat_index() -> int:
	return current_beat_index

func get_total_beats() -> int:
	if active_pattern in patterns:
		return patterns[active_pattern].beats.size()
	return 0
