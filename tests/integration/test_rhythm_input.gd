extends GutTest

var RhythmPattern = preload("res://scripts/input/rhythm_pattern.gd")

var rhythm: Node

func before_each():
	rhythm = RhythmPattern.new()
	add_child_autofree(rhythm)

func test_rhythm_pattern_loads():
	assert_not_null(rhythm, "Rhythm pattern should load")

func test_rhythm_pattern_has_patterns():
	assert_true(rhythm.patterns.size() > 0, "Should have pattern definitions")

func test_rhythm_pattern_has_spark():
	assert_true("spark" in rhythm.patterns, "Should have spark pattern")

func test_rhythm_pattern_has_fireball():
	assert_true("fireball" in rhythm.patterns, "Should have fireball pattern")

func test_rhythm_pattern_has_lightning():
	assert_true("lightning" in rhythm.patterns, "Should have lightning pattern")

func test_rhythm_pattern_has_meteor():
	assert_true("meteor" in rhythm.patterns, "Should have meteor pattern")

func test_pattern_spell_mapping():
	assert_eq(rhythm.get_pattern_spell("spark"), "spark")
	assert_eq(rhythm.get_pattern_spell("fireball"), "fireball")
	assert_eq(rhythm.get_pattern_spell("lightning"), "lightning")
	assert_eq(rhythm.get_pattern_spell("meteor"), "meteor")

func test_pattern_complexity():
	assert_eq(rhythm.get_pattern_complexity("spark"), 1)
	assert_eq(rhythm.get_pattern_complexity("fireball"), 2)
	assert_eq(rhythm.get_pattern_complexity("lightning"), 3)
	assert_eq(rhythm.get_pattern_complexity("meteor"), 4)

func test_initial_state():
	assert_false(rhythm.is_pattern_active(), "No pattern should be active initially")
	assert_eq(rhythm.get_current_beat_index(), 0, "Beat index should be 0")

func test_start_pattern():
	var result = rhythm.start_pattern("spark")
	assert_true(result, "Should return true for valid pattern")
	assert_true(rhythm.is_pattern_active(), "Pattern should be active")
	assert_eq(rhythm.active_pattern, "spark", "Active pattern should be spark")

func test_start_invalid_pattern():
	var result = rhythm.start_pattern("nonexistent")
	assert_false(result, "Should return false for invalid pattern")
	assert_false(rhythm.is_pattern_active(), "No pattern should be active")

func test_cancel_pattern():
	rhythm.start_pattern("spark")
	rhythm.cancel_pattern()
	assert_false(rhythm.is_pattern_active(), "Pattern should not be active after cancel")

func test_get_pattern_beats():
	var beats = rhythm.get_pattern_beats("spark")
	assert_eq(beats.size(), 3, "Spark should have 3 beats")
	assert_eq(beats[0], 0.0, "First beat should be at 0")

func test_get_total_beats():
	rhythm.start_pattern("spark")
	assert_eq(rhythm.get_total_beats(), 3, "Spark should have 3 total beats")

func test_accuracy_perfect():
	var accuracy = rhythm._calculate_accuracy(0.05)  # Within perfect window
	assert_eq(accuracy, 1.0, "Should be perfect accuracy")

func test_accuracy_good():
	var accuracy = rhythm._calculate_accuracy(0.12)  # Within good window
	assert_eq(accuracy, 0.8, "Should be good accuracy")

func test_accuracy_ok():
	var accuracy = rhythm._calculate_accuracy(0.2)  # Within ok window
	assert_eq(accuracy, 0.5, "Should be ok accuracy")

func test_accuracy_miss():
	var accuracy = rhythm._calculate_accuracy(0.5)  # Outside all windows
	assert_eq(accuracy, 0.0, "Should be a miss")

func test_unknown_pattern_returns_empty():
	assert_eq(rhythm.get_pattern_spell("unknown"), "")
	assert_eq(rhythm.get_pattern_complexity("unknown"), 0)
	assert_eq(rhythm.get_pattern_beats("unknown").size(), 0)
