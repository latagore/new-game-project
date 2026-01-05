extends GutTest

var GestureRecognizer = preload("res://scripts/input/gesture_recognizer.gd")

var recognizer: Node

func before_each():
	recognizer = GestureRecognizer.new()
	add_child_autofree(recognizer)

func test_gesture_recognizer_loads():
	assert_not_null(recognizer, "Gesture recognizer should load")

func test_gesture_recognizer_has_gestures():
	assert_true(recognizer.gestures.size() > 0, "Should have gesture definitions")

func test_gesture_recognizer_has_line():
	assert_true("line" in recognizer.gestures, "Should have line gesture")

func test_gesture_recognizer_has_circle():
	assert_true("circle" in recognizer.gestures, "Should have circle gesture")

func test_gesture_recognizer_has_triangle():
	assert_true("triangle" in recognizer.gestures, "Should have triangle gesture")

func test_gesture_spell_mapping():
	assert_eq(recognizer.get_gesture_spell("line"), "magic_missile")
	assert_eq(recognizer.get_gesture_spell("circle"), "shield")
	assert_eq(recognizer.get_gesture_spell("triangle"), "fireball")

func test_gesture_complexity():
	assert_eq(recognizer.get_gesture_complexity("line"), 1)
	assert_eq(recognizer.get_gesture_complexity("circle"), 2)
	assert_eq(recognizer.get_gesture_complexity("triangle"), 3)
	assert_eq(recognizer.get_gesture_complexity("star"), 5)

func test_initial_state():
	assert_false(recognizer.is_drawing, "Should not be drawing initially")
	assert_eq(recognizer.points.size(), 0, "Points should be empty")

func test_check_line_straight():
	# Simulate a straight horizontal line
	recognizer.points.clear()
	recognizer.points.append(Vector2(0, 100))
	recognizer.points.append(Vector2(50, 100))
	recognizer.points.append(Vector2(100, 100))
	recognizer.points.append(Vector2(150, 100))
	recognizer.points.append(Vector2(200, 100))

	var confidence = recognizer._check_line()
	assert_gt(confidence, 0.9, "Straight line should have high confidence")

func test_check_line_curved():
	# Simulate a curved path
	recognizer.points.clear()
	recognizer.points.append(Vector2(0, 0))
	recognizer.points.append(Vector2(50, 50))
	recognizer.points.append(Vector2(100, 0))
	recognizer.points.append(Vector2(150, 50))
	recognizer.points.append(Vector2(200, 0))

	var confidence = recognizer._check_line()
	assert_lt(confidence, 0.75, "Curved path should have lower line confidence")

func test_check_line_too_short():
	recognizer.points.clear()
	recognizer.points.append(Vector2(0, 0))
	recognizer.points.append(Vector2(10, 0))

	var confidence = recognizer._check_line()
	assert_eq(confidence, 0.0, "Too short line should return 0")

func test_check_circle_round():
	# Simulate a circle (points around center)
	var center = Vector2(100, 100)
	var radius = 50.0
	recognizer.points.clear()
	for i in range(16):
		var angle = i * TAU / 16
		recognizer.points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	# Close the circle
	recognizer.points.append(recognizer.points[0])

	var confidence = recognizer._check_circle()
	assert_gt(confidence, 0.7, "Round closed shape should have high circle confidence")

func test_check_v_shape():
	# Simulate a V shape (down then up)
	recognizer.points.clear()
	recognizer.points.append(Vector2(0, 0))
	recognizer.points.append(Vector2(25, 50))
	recognizer.points.append(Vector2(50, 100))  # Bottom vertex
	recognizer.points.append(Vector2(75, 50))
	recognizer.points.append(Vector2(100, 0))

	var confidence = recognizer._check_v_shape()
	assert_gt(confidence, 0.5, "V shape should be recognized")

func test_unknown_gesture_returns_empty():
	assert_eq(recognizer.get_gesture_spell("unknown"), "")
	assert_eq(recognizer.get_gesture_complexity("unknown"), 0)
