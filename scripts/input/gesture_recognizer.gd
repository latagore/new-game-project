class_name GestureRecognizer
extends Node

## Recognizes mouse gesture shapes and emits signals when patterns are detected.
## Shapes: line, circle, v_shape, triangle, star

signal gesture_recognized(gesture_name: String, power: float)
signal gesture_failed()
signal drawing_started()
signal drawing_updated(points: Array)

# Configuration
@export var min_points: int = 5
@export var max_time: float = 2.0  # Max time to complete gesture
@export var line_tolerance: float = 0.15  # How straight a line must be (0-1)
@export var circle_tolerance: float = 0.2  # How round a circle must be

# State
var is_drawing: bool = false
var points: Array[Vector2] = []
var draw_start_time: float = 0.0

# Gesture definitions
var gestures = {
	"line": {"complexity": 1, "spell": "magic_missile"},
	"circle": {"complexity": 2, "spell": "shield"},
	"v_shape": {"complexity": 2, "spell": "fire_arrow"},
	"triangle": {"complexity": 3, "spell": "fireball"},
	"star": {"complexity": 5, "spell": "meteor"},
}

func _ready():
	set_process_input(true)

func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_start_drawing(event.position)
			else:
				_finish_drawing()

	elif event is InputEventMouseMotion and is_drawing:
		_add_point(event.position)

func _start_drawing(pos: Vector2):
	is_drawing = true
	points.clear()
	points.append(pos)
	draw_start_time = Time.get_ticks_msec() / 1000.0
	drawing_started.emit()

func _add_point(pos: Vector2):
	# Don't add if too close to last point
	if points.size() > 0 and points[-1].distance_to(pos) < 5:
		return

	points.append(pos)
	drawing_updated.emit(points)

	# Check timeout
	var elapsed = Time.get_ticks_msec() / 1000.0 - draw_start_time
	if elapsed > max_time:
		_finish_drawing()

func _finish_drawing():
	if not is_drawing:
		return

	is_drawing = false

	if points.size() < min_points:
		gesture_failed.emit()
		return

	var result = _recognize_gesture()
	if result.gesture != "":
		gesture_recognized.emit(result.gesture, result.power)
	else:
		gesture_failed.emit()

func _recognize_gesture() -> Dictionary:
	# Try each gesture type and return best match
	var best_match = {"gesture": "", "power": 0.0, "confidence": 0.0}

	# Check line
	var line_conf = _check_line()
	if line_conf > 0.7 and line_conf > best_match.confidence:
		best_match = {"gesture": "line", "power": line_conf, "confidence": line_conf}

	# Check circle
	var circle_conf = _check_circle()
	if circle_conf > 0.6 and circle_conf > best_match.confidence:
		best_match = {"gesture": "circle", "power": circle_conf, "confidence": circle_conf}

	# Check V shape
	var v_conf = _check_v_shape()
	if v_conf > 0.6 and v_conf > best_match.confidence:
		best_match = {"gesture": "v_shape", "power": v_conf, "confidence": v_conf}

	# Check triangle
	var tri_conf = _check_triangle()
	if tri_conf > 0.5 and tri_conf > best_match.confidence:
		best_match = {"gesture": "triangle", "power": tri_conf, "confidence": tri_conf}

	return best_match

func _check_line() -> float:
	if points.size() < 2:
		return 0.0

	var start = points[0]
	var end = points[-1]
	var line_length = start.distance_to(end)

	if line_length < 50:  # Too short
		return 0.0

	# Calculate total path length
	var path_length = 0.0
	for i in range(1, points.size()):
		path_length += points[i - 1].distance_to(points[i])

	# Perfect line: path_length == line_length
	# Ratio close to 1 = straight line
	var straightness = line_length / max(path_length, 1.0)
	return clampf(straightness, 0.0, 1.0)

func _check_circle() -> float:
	if points.size() < 8:
		return 0.0

	# Find center (average of all points)
	var center = Vector2.ZERO
	for p in points:
		center += p
	center /= points.size()

	# Calculate average radius
	var avg_radius = 0.0
	for p in points:
		avg_radius += center.distance_to(p)
	avg_radius /= points.size()

	if avg_radius < 20:  # Too small
		return 0.0

	# Check if points are evenly distributed around center
	var variance = 0.0
	for p in points:
		var dist = center.distance_to(p)
		variance += abs(dist - avg_radius)
	variance /= points.size()

	# Check if start and end are close (closed shape)
	var closure = 1.0 - clampf(points[0].distance_to(points[-1]) / avg_radius, 0.0, 1.0)

	# Combine metrics
	var roundness = 1.0 - clampf(variance / avg_radius, 0.0, 1.0)
	return (roundness * 0.7 + closure * 0.3)

func _check_v_shape() -> float:
	if points.size() < 5:
		return 0.0

	# Find the lowest point (vertex of V)
	var lowest_idx = 0
	var lowest_y = points[0].y
	for i in range(points.size()):
		if points[i].y > lowest_y:
			lowest_y = points[i].y
			lowest_idx = i

	# Vertex should be roughly in the middle
	var vertex_position = float(lowest_idx) / float(points.size())
	if vertex_position < 0.2 or vertex_position > 0.8:
		return 0.0

	# Check that we go down then up
	var left_segment = points.slice(0, lowest_idx + 1)
	var right_segment = points.slice(lowest_idx)

	if left_segment.size() < 2 or right_segment.size() < 2:
		return 0.0

	# Left should trend downward, right should trend upward
	var left_trend = left_segment[-1].y - left_segment[0].y  # Positive = going down
	var right_trend = right_segment[-1].y - right_segment[0].y  # Negative = going up

	if left_trend < 20 or right_trend > -20:
		return 0.0

	# Check straightness of each segment
	var left_straight = _segment_straightness(left_segment)
	var right_straight = _segment_straightness(right_segment)

	return (left_straight + right_straight) / 2.0

func _check_triangle() -> float:
	if points.size() < 10:
		return 0.0

	# Find 3 corners (points with sharpest angle changes)
	var corners = _find_corners(3)
	if corners.size() < 3:
		return 0.0

	# Check if start and end are close (closed shape)
	var closure = points[0].distance_to(points[-1])
	var perimeter = 0.0
	for i in range(1, points.size()):
		perimeter += points[i - 1].distance_to(points[i])

	var closure_ratio = 1.0 - clampf(closure / (perimeter * 0.2), 0.0, 1.0)

	# Check if corners form reasonable triangle
	var corner_points = [points[corners[0]], points[corners[1]], points[corners[2]]]
	var side1 = corner_points[0].distance_to(corner_points[1])
	var side2 = corner_points[1].distance_to(corner_points[2])
	var side3 = corner_points[2].distance_to(corner_points[0])

	# Sides should be somewhat similar (not too degenerate)
	var avg_side = (side1 + side2 + side3) / 3.0
	var side_variance = (abs(side1 - avg_side) + abs(side2 - avg_side) + abs(side3 - avg_side)) / 3.0
	var regularity = 1.0 - clampf(side_variance / avg_side, 0.0, 1.0)

	return closure_ratio * 0.5 + regularity * 0.5

func _segment_straightness(segment: Array) -> float:
	if segment.size() < 2:
		return 0.0

	var start = segment[0]
	var end = segment[-1]
	var line_length = start.distance_to(end)

	if line_length < 10:
		return 0.0

	var path_length = 0.0
	for i in range(1, segment.size()):
		path_length += segment[i - 1].distance_to(segment[i])

	return clampf(line_length / max(path_length, 1.0), 0.0, 1.0)

func _find_corners(count: int) -> Array[int]:
	if points.size() < count * 2:
		return []

	var angles: Array[Dictionary] = []

	# Calculate angle change at each point
	for i in range(1, points.size() - 1):
		var v1 = points[i] - points[i - 1]
		var v2 = points[i + 1] - points[i]
		var angle = abs(v1.angle_to(v2))
		angles.append({"index": i, "angle": angle})

	# Sort by angle (sharpest first)
	angles.sort_custom(func(a, b): return a.angle > b.angle)

	# Return top corners, ensuring they're spread out
	var result: Array[int] = []
	var min_distance = points.size() / (count + 1)

	for a in angles:
		var valid = true
		for existing in result:
			if abs(a.index - existing) < min_distance:
				valid = false
				break
		if valid:
			result.append(a.index)
		if result.size() >= count:
			break

	result.sort()
	return result

# Public API
func get_gesture_spell(gesture_name: String) -> String:
	if gesture_name in gestures:
		return gestures[gesture_name].spell
	return ""

func get_gesture_complexity(gesture_name: String) -> int:
	if gesture_name in gestures:
		return gestures[gesture_name].complexity
	return 0
