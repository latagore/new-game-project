extends Node2D

var calculations_per_frame = 1000
var calculation_type = "math"

var test_array = []
var test_dictionary = {}

@onready var fps_label = $CanvasLayer/FPSLabel
@onready var control_label = $CanvasLayer/ControlLabel
@onready var stats_label = $CanvasLayer/StatsLabel

func _ready():
	control_label.text = "[1] Math Ops  [2] Array Ops  [3] Dictionary Ops  [4] String Ops\n[Q] x2 Calculations  [A] /2 Calculations\n[W] x10 Calculations  [S] /10 Calculations"
	
	for i in range(10000):
		test_array.append(i)
		test_dictionary[i] = i * 2

func _process(_delta):
	var type_display = {
		"math": "MATH OPS (sin/cos/sqrt/pow)",
		"array": "ARRAY OPS (access/modify/sort)",
		"dictionary": "DICTIONARY OPS (lookup/update)",
		"string": "STRING OPS (concat/split)"
	}
	
	fps_label.text = "FPS: %d | Calcs: %s\n[%s]" % [
		Engine.get_frames_per_second(),
		_format_number(calculations_per_frame),
		type_display[calculation_type]
	]
	
	var start_time = Time.get_ticks_usec()
	
	match calculation_type:
		"math":
			_perform_math_calculations()
		"array":
			_perform_array_operations()
		"dictionary":
			_perform_dictionary_operations()
		"string":
			_perform_string_operations()
	
	var elapsed = Time.get_ticks_usec() - start_time
	
	stats_label.text = "Memory: %.2f MB\nPhysics Time: %.2f ms\nProcess Time: %.2f ms\nCalc Time: %.2f ms" % [
		OS.get_static_memory_usage() / 1024.0 / 1024.0,
		Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		elapsed / 1000.0
	]
	
	if Input.is_physical_key_pressed(KEY_1):
		calculation_type = "math"
	elif Input.is_physical_key_pressed(KEY_2):
		calculation_type = "array"
	elif Input.is_physical_key_pressed(KEY_3):
		calculation_type = "dictionary"
	elif Input.is_physical_key_pressed(KEY_4):
		calculation_type = "string"
	elif Input.is_key_pressed(KEY_Q):
		calculations_per_frame = int(calculations_per_frame * 2)
	elif Input.is_key_pressed(KEY_A):
		calculations_per_frame = max(1, int(calculations_per_frame / 2))
	elif Input.is_key_pressed(KEY_W):
		calculations_per_frame = int(calculations_per_frame * 10)
	elif Input.is_key_pressed(KEY_S):
		calculations_per_frame = max(1, int(calculations_per_frame / 10))

func _perform_math_calculations():
	var result = 0.0
	for i in range(calculations_per_frame):
		result += sin(i) * cos(i) + sqrt(abs(i)) + pow(i % 10, 2)

func _perform_array_operations():
	for i in range(calculations_per_frame):
		var idx = i % test_array.size()
		var value = test_array[idx]
		test_array[idx] = value + 1
		if i % 100 == 0:
			test_array.sort()

func _perform_dictionary_operations():
	for i in range(calculations_per_frame):
		var key = i % test_dictionary.size()
		test_dictionary[key] = test_dictionary.get(key, 0) + 1
		if i % 100 == 0:
			var _keys = test_dictionary.keys()

func _perform_string_operations():
	for i in range(calculations_per_frame):
		var s = str(i)
		s = s + "_test_" + str(i * 2)
		var _parts = s.split("_")
		var _length = s.length()

func _format_number(num: int) -> String:
	if num >= 1000000:
		return "%.1fM" % (num / 1000000.0)
	elif num >= 1000:
		return "%.1fK" % (num / 1000.0)
	else:
		return str(num)

